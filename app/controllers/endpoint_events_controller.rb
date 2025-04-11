class EndpointEventsController < ApplicationController
  before_action :authenticate_account!

  REQUEST_DELAY_THRESHOLD = 60 # millis
  TYPE_MAP = {
    "SshRejectionEvent" => SshRejectionEvent
  }.freeze

  class UnsupportedTypeError < StandardError; end

  def create
    event = type_from_params.create!(endpoint_event_params.merge(account: current_account))
    render json: { message: "Event created successfully" }, status: :created
  rescue UnsupportedTypeError, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  protected

  def endpoint_event_params
    params.require(:endpoint_event)
    metadata_params = type_from_params.declared_schema.keys
    raise UnsupportedTypeError, "Unsupported event type: #{type_from_params}" unless metadata_params
    params.require(:endpoint_event)
      .permit(:event_type, :endpoint_id, raw_metadata: metadata_params)
      .to_h
      .except(:event_type)
  end

  def type_from_params
    @type_from_params ||= TYPE_MAP[params[:endpoint_event][:event_type]].tap do |type|
      raise UnsupportedTypeError, "Unsupported event type: #{params[:endpoint_event][:event_type]}" unless type
    end
  end

  def authenticate_account!
    authenticate_or_request_with_http_token do |token, options|
      digest = OpenSSL::Digest.new("sha256")
      data = request.body.read + options[:timestamp]
      request.body.rewind
      current_timestamp = (Time.now.to_f * 1000).to_i
      return false if (current_timestamp - options[:timestamp].to_i).abs > REQUEST_DELAY_THRESHOLD
      signature = OpenSSL::HMAC.hexdigest(digest, token, data)
      ActiveSupport::SecurityUtils.secure_compare(signature, options[:signature]) &&
        @current_account = Account.find_by(public_token: options[:public_token]).authenticate_token(token)
    end
  end

  def current_account
    @current_account
  end
end
