class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.integer :role, null: false
      t.integer :status, null: false, default: 0
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.datetime :approved_at
      t.references :company, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, :email
  end
end
