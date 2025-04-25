class EndpointEvent < ApplicationRecord
  self.inheritance_column = :event_type
  class_attribute :declared_schema, instance_writer: false, default: {}

  belongs_to :account

  validates_presence_of :endpoint_id, :raw_metadata
  validates_uniqueness_of :message_id, scope: :endpoint_id
  validate :validate_metadata_schema

  ENABLED_FACTS = [
    SshRejectionFact
  ].freeze

  def self.schema(hash)
    self.declared_schema = hash
  end

  def event_schema
    self.class.declared_schema
  end

  def metadata
    @metadata ||= raw_metadata
  end

  def facts
    @facts ||= ENABLED_FACTS.flat_map do |fact_class|
      fact_class.from_event(self)
    end
  end

  def validate_metadata_schema
    if raw_metadata.blank?
      errors.add(:raw_metadata, "metadata cannot be blank")
      return
    end

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
