class CreateSshRejectionFacts < ActiveRecord::Migration[8.0]
  def change
    create_table :ssh_rejection_facts do |t|
      t.string :ip
      t.integer :port
      t.string :ip_location
      t.datetime :timestamp, null: false
      t.references :endpoint_event, null: false, foreign_key: false

      t.timestamps
    end
  end
end
