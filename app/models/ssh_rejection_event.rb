class SshRejectionEvent < EndpointEvent
  schema ip: String, port: Integer, user: String

  def ip = metadata&.fetch("ip", nil)
  def port = metadata&.fetch("port", nil)
  def user = metadata&.fetch("user", nil)
end
