require "test_helper"

class SshRejectionFactTest < ActiveSupport::TestCase
  fixtures :accounts, :ssh_rejection_events

  test "creates a new fact from an event" do
    ssh_event = ssh_rejection_events(:one)
    fact = SshRejectionFact.from_event(ssh_event).tap(&:save!)
    assert fact.persisted?, "Fact should be saved to the database"
    assert_equal ssh_event.ip, fact.ip
    assert_equal ssh_event.port, fact.port
    assert_equal "unknown", fact.ip_location

    assert_equal ssh_event.facts, [fact], "Fact should be associated with the event"
  end
end
