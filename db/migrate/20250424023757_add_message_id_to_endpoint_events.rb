class AddMessageIdToEndpointEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :endpoint_events, :message_id, :string, null: false

    add_index :endpoint_events, [ :endpoint_id, :message_id ], unique: true
  end
end
