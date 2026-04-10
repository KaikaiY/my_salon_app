class AddUniqueIndexToTimeSlots < ActiveRecord::Migration[7.1]
  def change
    add_index :time_slots,
              %i[treatment_day_id start_time end_time],
              unique: true,
              name: "index_time_slots_on_day_and_time_range"
  end
end
