require 'rails_helper'

RSpec.describe Invitation, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(FactoryBot.build(:invitation)).to be_valid
    end

    it 'admin role では無効であること' do
      invitation = FactoryBot.build(:invitation, role: :admin)

      expect(invitation).to be_invalid
      expect(invitation.errors[:role]).to include 'は指定できません'
    end

    it 'expires_at が過去日時だと無効であること' do
      invitation = FactoryBot.build(:invitation, expires_at: 1.day.ago)

      expect(invitation).to be_invalid
      expect(invitation.errors[:expires_at]).to include 'は過去の日付です'
    end

    it '不正なメールアドレスでは無効であること' do
      invitation = FactoryBot.build(:invitation, email: 'invalid_email')
      invitation.valid?

      expect(invitation.errors[:email]).to be_present
    end

    it 'therapist は company がなくても有効であること' do
      invitation = build(:invitation, role: :therapist, company: nil)

      expect(invitation).to be_valid
    end

    it 'company_manager は company がないと無効であること' do
      invitation = build(:invitation, role: :company_manager, company: nil)
      invitation.valid?

      expect(invitation.errors[:company]).to be_present
    end

    it 'employee は company がないと無効であること' do
      invitation = build(:invitation, role: :employee, company: nil)
      invitation.valid?

      expect(invitation.errors[:company]).to be_present
    end
  end

  describe '#available_for_signup?' do
    it 'pending かつ有効期限内なら true を返すこと' do
      invitation = FactoryBot.build(:invitation, status: :pending)
      expect(invitation.available_for_signup?).to be true
    end

    it 'accepted なら false を返すこと' do
      invitation = FactoryBot.build(:invitation, status: :accepted)
      expect(invitation.available_for_signup?).to be false
    end

    it '有効期限切れなら false を返すこと' do
      invitation = FactoryBot.build(:invitation, expires_at: 1.day.ago)
      expect(invitation.available_for_signup?).to be false
    end
  end
  describe '#mark_as_expired_if_needed!' do
    it '期限内の pending 招待は expired にしないこと' do
      invitation = FactoryBot.create(:invitation, status: :pending)
      invitation.mark_as_expired_if_needed!

      expect(invitation.status).to eq('pending')
    end
  end
end
