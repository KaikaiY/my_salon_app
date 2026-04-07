class CreateTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :time_slots do |t|
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.references :treatment_day, null: false, foreign_key: true

      t.timestamps
    end
  end
end
