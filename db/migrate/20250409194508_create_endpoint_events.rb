class CreateEndpointEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :endpoint_events do |t|
      t.string :event_type
      t.string :endpoint_id
      t.jsonb :raw_metadata

      t.timestamps
    end
    add_index :endpoint_events, :endpoint_id
  end
end
