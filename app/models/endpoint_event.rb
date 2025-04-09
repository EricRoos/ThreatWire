class EndpointEvent < ApplicationRecord
  self.inheritance_column = :event_type
  validates_presence_of :endpoint_id, :raw_metadata
  validate :validate_metadata_schema

  # Example schema
  #  {
  #    ip: String.class,
  #    port: Integer.class,
  #    user: String.class
  #  }
  def event_schema
    raise "NotImplementedError"
  end

  def metadata
    @metadata ||= raw_metadata
  end

  def ip = metadata["ip"] rescue nil
  def port = metadata["port"] rescue nil
  def user = metadata["user"] rescue nil

  private

  # Validate that the raw metadata matches the expected schema

  def validate_metadata_schema
    return if raw_metadata.blank?
    event_schema.each do |key, value|
      unless metadata.key?(key.to_s) && metadata[key.to_s].is_a?(value)
        errors.add(:raw_metadata, "Invalid schema for key #{key}: expected #{value}, got #{metadata[key.to_s].class}")
      end
    end
  end
end
