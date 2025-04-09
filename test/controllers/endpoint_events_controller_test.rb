require "test_helper"

class EndpointEventsControllerTest < ActionDispatch::IntegrationTest
  test "should get created" do
    params = { endpoint_event: {
      event_type: "SshRejectionEvent",
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: "127.0.0.1",
        port: 22,
        user: "root"
      }
    } }


    post(endpoint_events_url, params:, as: :json)
    assert_response :success
  end

  test "rejects due to bad schema type" do
    params = { endpoint_event: {
      event_type: "SshRejectionEvent",
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: -1,
        port: 22,
        user: "root"
      }
    } }


    post(endpoint_events_url, params:, as: :json)
    assert_response :unprocessable_entity
  end

  test "rejects due to missing metadata" do
    params = { endpoint_event: {
      event_type: "SshRejectionEvent",
      endpoint_id: SecureRandom.uuid
    } }


    post(endpoint_events_url, params:, as: :json)
    assert_response :unprocessable_entity
  end

  test "rejects due to missing type" do
    params = { endpoint_event: {
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: -1,
        port: 22,
        user: "root"
      }
    } }

    post(endpoint_events_url, params:, as: :json)
    assert_response :unprocessable_entity
  end

  test "rejects due to bad type" do
    params = { endpoint_event: {
      event_type: "DoesNotExist",
      endpoint_id: SecureRandom.uuid,
      raw_metadata: {
        ip: -1,
        port: 22,
        user: "root"
      }
    } }


    post(endpoint_events_url, params:, as: :json)
    assert_response :unprocessable_entity
  end

  test "rejects due to missing params" do
    params = {}
    post(endpoint_events_url, params:, as: :json)
    assert_response :unprocessable_entity
  end
end
