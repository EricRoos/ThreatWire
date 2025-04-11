class EndpointEvent < ApplicationRecord
  self.inheritance_column = :event_type
  class_attribute :declared_schema, instance_writer: false, default: {}

  belongs_to :account

  validates_presence_of :endpoint_id, :raw_metadata
  validate :validate_metadata_schema

  def self.schema(hash)
    self.declared_schema = hash
  end

  def event_schema
    self.class.declared_schema
  end

  def metadata
    @metadata ||= raw_metadata
  end

  def ip = metadata&.fetch("ip", nil)
  def port = metadata&.fetch("port", nil)
  def user = metadata&.fetch("user", nil)

  private

  def validate_metadata_schema
    return if raw_metadata.blank?

    event_schema.each do |key, expected_class|
      actual_value = metadata[key.to_s]
      unless actual_value.is_a?(expected_class)
        errors.add(
          :raw_metadata,
          "Invalid schema for key '#{key}': expected #{expected_class}, got #{actual_value.inspect} (#{actual_value.class})"
        )
      end
    end

    extra_keys = metadata.keys - event_schema.keys.map(&:to_s)
    return if extra_keys.empty?
    errors.add("raw_metadata", "Extra keys in metadata: #{extra_keys.join(', ')}")
  end
end
