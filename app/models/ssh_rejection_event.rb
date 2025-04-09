class SshRejectionEvent < EndpointEvent
  def self.event_schema
    {
      ip: String,
      port: Integer,
      user: String
    }
  end

  def event_schema
    self.class.event_schema
  end
end
