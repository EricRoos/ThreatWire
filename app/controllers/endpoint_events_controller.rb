class EndpointEventsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]
  before_action :authenticate_account!

  REQUEST_DELAY_THRESHOLD = 1000 # millis
  TYPE_MAP = {
    "SshRejectionEvent" => SshRejectionEvent
  }.freeze

  class UnsupportedTypeError < StandardError; end
  class InvalidMetadataError < StandardError; end

  def create
    endpoint_event = type_from_params.new(endpoint_event_params.to_h)
    endpoint_event.validate_metadata_schema
    if endpoint_event.errors[:raw_metadata].any?
      raise InvalidMetadataError, "Invalid metadata schema"
    end
    EndpointEventCreateService.new(
      event_klazz: type_from_params,
      account_id: current_account.id,
      event_params: endpoint_event_params.to_h
    ).call_later

    render json: { message: "Event created successfully" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue UnsupportedTypeError, InvalidMetadataError => e
    render json: { error: e.message }, status: :bad_request
  end

  protected

  def request_received_at
    @request_received_at ||= begin
      header_time = request.headers["X-Started-At"]
      (header_time.present? ? header_time.to_f : Time.now.to_f) * 1000
    end.to_i
  end

  def endpoint_event_params
    params.require(:endpoint_event)
    metadata_params = type_from_params.declared_schema.keys
    raise UnsupportedTypeError, "Unsupported event type: #{type_from_params}" unless metadata_params
    params.require(:endpoint_event)
      .permit(:event_type, :endpoint_id, :timestamp, :message_id, raw_metadata: metadata_params)
      .to_h
      .except(:event_type)
      .tap do |event_params|
        event_params[:timestamp] = Time.at(event_params[:timestamp].to_i / 1000)
      end
  end

  def type_from_params
    @type_from_params ||= TYPE_MAP[params[:endpoint_event][:event_type]].tap do |type|
      raise UnsupportedTypeError, "Unsupported event type: #{params[:endpoint_event][:event_type]}" unless type
    end
  end

  def authenticate_account!
    authenticate_or_request_with_http_token do |token, options|
      @current_account = nil
      return false unless token && options[:public_token] && options[:signature] && options[:timestamp]

      delta_time = (request_received_at - options[:timestamp].to_i).abs
      return false if delta_time > REQUEST_DELAY_THRESHOLD

      account = Account.find_by(public_token: options[:public_token])
      return false unless account
      return false unless account.authenticate_token(token)

      body_data = request.body.read
      request.body.rewind
      data = body_data + options[:timestamp]
      valid_signature = ActiveSupport::SecurityUtils.secure_compare(
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), token, data),
        options[:signature]
      )
      return false unless valid_signature

      @current_account = account
    end
  end

  def current_account
    @current_account
  end
end
