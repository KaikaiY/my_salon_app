class CreateTreatmentDays < ActiveRecord::Migration[7.1]
  def change
    create_table :treatment_days do |t|
      t.date :date, null: false
      t.integer :booking_source, null: false
      t.integer :status, null: false, default: 0
      t.text :note
      t.references :company, null: false, foreign_key: true
      t.references :therapist, foreign_key: { to_table: :users }
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
