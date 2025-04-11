class SshRejectionEvent < EndpointEvent
  schema ip: String, port: Integer, user: String
end
