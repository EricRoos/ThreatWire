class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :public_token
      t.string :token
      t.string :token_digest

      t.timestamps
    end
    add_index :accounts, :token, unique: true
  end
end
