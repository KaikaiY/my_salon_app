require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(FactoryBot.build(:company)).to be_valid
    end

    it 'company_name がないと無効であること' do
      company = FactoryBot.build(:company, company_name: nil)
      company.valid?

      expect(company.errors[:company_name]).to be_present
    end

    it 'email がないと無効であること' do
      company = FactoryBot.build(:company, email: nil)
      company.valid?

      expect(company.errors[:email]).to be_present
    end

    it '不正なメールアドレスでは無効であること' do
      company = FactoryBot.build(:company, email: 'invalid_email')
      company.valid?

      expect(company.errors[:email]).to be_present
    end

    it 'phone がないと無効であること' do
      company = FactoryBot.build(:company, phone: nil)
      company.valid?

      expect(company.errors[:phone]).to be_present
    end

    it 'phone が10桁の数字なら有効であること' do
      company = build(:company, phone: '1234567890')
      expect(company).to be_valid
    end
    it 'phone が11桁の数字なら有効であること' do
      company = FactoryBot.build(:company, phone: '12345678901')
      expect(company).to be_valid
    end

    it 'phone が数字以外を含むと無効であること' do
      company = FactoryBot.build(:company, phone: 'invalid')
      company.valid?

      expect(company.errors[:phone]).to be_present
    end
  end
end
