class EndpointEventsController < ApplicationController
  TYPE_MAP = {
    "SshRejectionEvent" => SshRejectionEvent
  }.freeze

  class UnsupportedTypeError < StandardError; end

  def create
    event = type_from_params.create!(endpoint_event_params)
    render json: { message: "Event created successfully" }, status: :created
  rescue UnsupportedTypeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  protected

  def endpoint_event_params
    params.require(:endpoint_event)
    return ssh_rejection_event_params if type_from_params == SshRejectionEvent
    raise UnsupportedTypeError, "Unsupported event type: #{type_from_params}"
  end

  def ssh_rejection_event_params
    params.require(:endpoint_event).permit(:endpoint_id, raw_metadata: [ :ip, :port, :user ])
  end

  def type_from_params
    @type_from_params ||= TYPE_MAP[params[:endpoint_event][:event_type]].tap do |type|
      raise UnsupportedTypeError, "Unsupported event type: #{params[:endpoint_event][:event_type]}" unless type
    end
  end
end
