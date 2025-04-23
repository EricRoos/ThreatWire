class IpLookupService
  def self.ip_db
    Ip2location.new.open(Rails.root.join("db","ipdb.BIN"))
  end

  def self.country_code_for(ip_address)
    ip_db.get_all(ip_address)["country_short"]
  end
end
