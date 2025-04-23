class ServiceCallJob < ApplicationJob
  queue_as :default

  def perform(service_object_clazz, kwargs)
    service_object = service_object_clazz.new(**kwargs)
    service_object.call
  end
end
