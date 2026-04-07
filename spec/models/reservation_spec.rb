require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(build(:reservation)).to be_valid
    end

    it 'status がないと無効であること' do
      reservation = build(:reservation, status: nil)

      expect(reservation).to be_invalid
      expect(reservation.errors[:status]).to be_present
    end

    it 'user がないと無効であること' do
      reservation = build(:reservation, user: nil)

      expect(reservation).to be_invalid
      expect(reservation.errors[:user]).to be_present
    end

    it 'time_slot がないと無効であること' do
      reservation = build(:reservation, time_slot: nil)

      expect(reservation).to be_invalid
      expect(reservation.errors[:time_slot]).to be_present
    end

    it '同じ time_slot に有効な予約がすでにあると無効であること' do
      time_slot = create(:time_slot)
      create(:reservation, time_slot: time_slot)

      reservation = build(:reservation, time_slot: time_slot)

      expect(reservation).to be_invalid
      expect(reservation.errors[:time_slot]).to be_present
    end
    
    it '同じ time_slot でも既存予約が cancelled なら有効であること' do
      time_slot = create(:time_slot)
      create(:reservation, :cancelled, time_slot: time_slot)

      reservation = build(:reservation, time_slot: time_slot)

      expect(reservation).to be_valid
    end
  end
end
