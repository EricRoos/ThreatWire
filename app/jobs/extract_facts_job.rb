class ExtractFactsJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.facts.each(&:save!)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to save facts for event #{event.id}: #{e.message}")
  end
end
