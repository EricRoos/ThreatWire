class EndpointEvent < ApplicationRecord
  self.abstract_class = true
  self.inheritence_column = :event_type
end
