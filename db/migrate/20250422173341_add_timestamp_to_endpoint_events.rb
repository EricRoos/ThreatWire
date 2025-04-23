class AddTimestampToEndpointEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :endpoint_events, :timestamp, :datetime
  end
end
