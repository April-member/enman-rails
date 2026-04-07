class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :invitation_token

      t.timestamps
    end

    add_index :tenants, :invitation_token, unique: true
  end
end
