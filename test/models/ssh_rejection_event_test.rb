class SshRejectionEventTest < ActiveSupport::TestCase
  fixtures :accounts

  def valid_params
    {
      account: accounts(:one),
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: "127.0.0.1",
        user: "root",
        port: 22
      }
    }
  end

  test "is valid with correct schema" do
    assert SshRejectionEvent.new(valid_params).valid?
  end

  test "is invalid without port" do
    params = valid_params
    params[:raw_metadata].delete(:port)
    event = SshRejectionEvent.new(params)
    assert_not event.valid?
    assert_includes event.errors[:raw_metadata].join, "port"
  end

  test "with extra metadata keys is invalid" do
    params = valid_params
    params[:raw_metadata][:extra_key] = "extra_value"
    event = SshRejectionEvent.new(params)
    assert_not event.valid?
    assert_includes event.errors[:raw_metadata].join, "extra_key"
  end
end
