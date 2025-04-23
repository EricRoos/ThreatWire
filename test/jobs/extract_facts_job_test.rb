require "test_helper"

class ExtractFactsJobTest < ActiveJob::TestCase
  fixtures :ssh_rejection_events
  test "perform" do
    event = ssh_rejection_events(:one)
    assert_difference "SshRejectionFact.count", 1 do
      ExtractFactsJob.perform_now(event)
    end
  end
end
