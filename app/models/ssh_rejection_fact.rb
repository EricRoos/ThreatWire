class SshRejectionFact < ApplicationRecord
  belongs_to :endpoint_event

  def self.from_event(event)
    case event
    in SshRejectionEvent => ssh_rejection_event
      existing_event = SshRejectionFact.find_by(endpoint_event: ssh_rejection_event)
      return existing_event if existing_event

      SshRejectionFact.new(
        endpoint_event: ssh_rejection_event,
        ip: ssh_rejection_event.ip,
        port: ssh_rejection_event.port,
        timestamp: ssh_rejection_event.timestamp,
        ip_location: IpLookupService.country_code_for(ssh_rejection_event.ip),
      )
    else
      nil
    end
  end
end
