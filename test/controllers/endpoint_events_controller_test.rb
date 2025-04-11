require "test_helper"

class EndpointEventsControllerTest < ActionDispatch::IntegrationTest
  fixtures :accounts

  def setup
    @account = accounts(:one)
  end

  def make_request(params, token = "secret_token", timestamp = (Time.now.to_f * 1000).to_i)
    @account.update(token:)

    data = params.to_json + timestamp.to_s
    digest = OpenSSL::Digest.new("sha256")
    signature = OpenSSL::HMAC.hexdigest(digest, token, data)

    headers = {
      "Authorization" => "Token token=#{token}, public_token=#{@account.public_token}, signature=#{signature}, timestamp=#{timestamp}"
    }
    post endpoint_events_url, params: params, headers: headers, as: :json
  end

  def base_params(overrides = {})
    {
      endpoint_event: {
        event_type: "SshRejectionEvent",
        endpoint_id: SecureRandom.uuid,
        raw_metadata: {
          ip: "127.0.0.1",
          port: 22,
          user: "root"
        }
      }
    }.deep_merge(endpoint_event: overrides)
  end

  test "creates a SshRejectionEvent successfully" do
    make_request(base_params)
    assert_response :success
  end

  test "rejects event with invalid IP format" do
    make_request(base_params(raw_metadata: { ip: -1 }))
    assert_response :unprocessable_entity
  end

  test "rejects event with missing raw_metadata" do
    params = base_params.tap do |p|
      p[:endpoint_event].delete(:raw_metadata)
    end
    make_request(params)
    assert_response :unprocessable_entity
  end

  test "rejects event with missing event_type" do
    params = base_params.tap do |p|
      p[:endpoint_event].delete(:event_type)
    end
    make_request(params)
    assert_response :unprocessable_entity
  end

  test "rejects event with unsupported event_type" do
    make_request(base_params(event_type: "DoesNotExist"))
    assert_response :unprocessable_entity
  end

  test "rejects request with empty params" do
    make_request({})
    assert_response :unprocessable_entity
  end
end
