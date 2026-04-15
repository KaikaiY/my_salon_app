require 'rails_helper'

RSpec.describe TreatmentDay, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(build(:treatment_day)).to be_valid
    end

    it 'date がないと無効であること' do
      treatment_day = build(:treatment_day, date: nil)

      expect(treatment_day).to be_invalid
      expect(treatment_day.errors[:date]).to be_present
    end

    it 'booking_source がないと無効であること' do
      treatment_day = build(:treatment_day, booking_source: nil)

      expect(treatment_day).to be_invalid
      expect(treatment_day.errors[:booking_source]).to be_present
    end

    it 'status がないと無効であること' do
      treatment_day = build(:treatment_day, status: nil)

      expect(treatment_day).to be_invalid
      expect(treatment_day.errors[:status]).to be_present
    end

    it 'therapist がなくても有効であること' do
      treatment_day = build(:treatment_day, therapist: nil)

      expect(treatment_day).to be_valid
    end
    it 'company がないと無効であること' do
      treatment_day = build(:treatment_day, company: nil)

      expect(treatment_day).to be_invalid
      expect(treatment_day.errors[:company]).to be_present
    end

    it 'created_by がないと無効であること' do
      treatment_day = build(:treatment_day, created_by: nil)

      expect(treatment_day).to be_invalid
      expect(treatment_day.errors[:created_by]).to be_present
    end
  end
end
