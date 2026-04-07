require 'rails_helper'

RSpec.describe TimeSlot, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(build(:time_slot)).to be_valid
    end

    it 'start_time がないと無効であること' do
      time_slot = build(:time_slot, start_time: nil)

      expect(time_slot).to be_invalid
      expect(time_slot.errors[:start_time]).to be_present
    end

    it 'end_time がないと無効であること' do
      time_slot = build(:time_slot, end_time: nil)

      expect(time_slot).to be_invalid
      expect(time_slot.errors[:end_time]).to be_present
    end

    it 'start_time が end_time 以降だと無効であること' do
      time_slot = build(:time_slot, start_time: "11:00", end_time: "10:00")

      expect(time_slot).to be_invalid
      expect(time_slot.errors[:start_time]).to be_present
    end

    it 'treatment_day がないと無効であること' do
      time_slot = build(:time_slot, treatment_day: nil)

      expect(time_slot).to be_invalid
      expect(time_slot.errors[:treatment_day]).to be_present
    end
  end
end
