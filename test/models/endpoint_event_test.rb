require "test_helper"

class EndpointEventTest < ActiveSupport::TestCase
  fixtures :accounts

  def valid_base_params(extra_params = {})
    {
      account: accounts(:one),
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {}
    }.merge(extra_params)
  end

  test "requires endpoint_id" do
    event = EndpointEvent.new(valid_base_params.except(:endpoint_id))
    assert_not event.valid?
    assert_includes event.errors[:endpoint_id], "can't be blank"
  end

  test "requires raw_metadata" do
    event = EndpointEvent.new(valid_base_params.except(:raw_metadata))
    assert_not event.valid?
    assert_includes event.errors[:raw_metadata], "can't be blank"
  end
end
