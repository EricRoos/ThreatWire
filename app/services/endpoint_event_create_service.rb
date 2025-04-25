class EndpointEventCreateService
  def initialize(event_klazz:, account_id:, event_params:)
    @context = {
      event_klazz: event_klazz,
      event_params: event_params,
      account_id: account_id
    }
  end

  def call
    @context => { event_klazz:, event_params:, account_id: }
    created_event = event_klazz.create!(event_params.merge(account_id:))
    ExtractFactsJob.perform_later(created_event) if created_event.persisted?
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
    Rails.logger.error("Caught error creating event: #{e.message}")
  end

  def call_later
    ServiceCallJob.perform_later(self.class, @context)
  end
end
