class AddAccountToEndpointEvent < ActiveRecord::Migration[8.0]
  def change
    add_reference :endpoint_events, :account, null: false, foreign_key: true
  end
end
