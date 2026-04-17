require 'rails_helper'

RSpec.describe TherapistProfile, type: :model do
  describe 'validations' do
    it 'bioがなければ無効であること' do
      therapist_profile = build(:therapist_profile, bio: nil)

      expect(therapist_profile).not_to be_valid
      expect(therapist_profile.errors[:bio]).to be_present
    end

    it 'specialtyがなければ無効であること' do
      therapist_profile = build(:therapist_profile, specialty: nil)

      expect(therapist_profile).not_to be_valid
      expect(therapist_profile.errors[:specialty]).to be_present
    end

    it 'careerがなければ無効であること' do
      therapist_profile = build(:therapist_profile, career: nil)

      expect(therapist_profile).not_to be_valid
      expect(therapist_profile.errors[:career]).to be_present
    end

    it '施術者でないuserでは無効であること' do
      employee = create(:user)
      therapist_profile = build(:therapist_profile, user: employee)

      expect(therapist_profile).not_to be_valid
      expect(therapist_profile.errors[:user]).to include('は施術者である必要があります')
    end

    it '同じuserにプロフィールを2つ作れないこと' do
      therapist = create(:user, :therapist)
      create(:therapist_profile, user: therapist)
      duplicate_profile = build(:therapist_profile, user: therapist)

      expect(duplicate_profile).not_to be_valid
      expect(duplicate_profile.errors[:user_id]).to be_present
    end
  end
end
