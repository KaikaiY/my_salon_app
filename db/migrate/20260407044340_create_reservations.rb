class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.integer :status, null: false, default: 0
      t.text :cancel_reason, null: true
      t.text :note, null: true
      t.references :user, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.timestamps
    end
  end
end
