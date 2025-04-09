require "test_helper"

class SshRejectionEventTest < ActiveSupport::TestCase
  test "a valid event" do
    SshRejectionEvent.create!(
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: "127.0.0.1",
        user: "root",
        port: 63123
      }
    )
  end
end
