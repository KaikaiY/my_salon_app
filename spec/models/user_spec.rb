require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '有効なfactoryを持つこと' do
      expect(FactoryBot.build(:user)).to be_valid
    end

    it 'name がないと無効であること' do
      user = FactoryBot.build(:user, name: nil)
      user.valid?

      expect(user.errors[:name]).to be_present
    end

    it 'role がないと無効であること' do
      user = FactoryBot.build(:user, role: nil)
      user.valid?

      expect(user.errors[:role]).to be_present
    end
    it 'email がないと無効であること' do
      user = FactoryBot.build(:user, email: nil)
      user.valid?

      expect(user.errors[:email]).to be_present
    end
    it 'password がないと無効であること' do
      user = FactoryBot.build(:user, password: nil)
      user.valid?

      expect(user.errors[:password]).to be_present
    end
    it 'therapist は company がなくても有効であること' do
      user = FactoryBot.build(:user, role: :therapist, company: nil)

      expect(user).to be_valid
    end

    it 'company_manager は company がないと無効であること' do
      user = FactoryBot.build(:user, role: :company_manager, company: nil)
      user.valid?

      expect(user.errors[:company]).to be_present
    end

    it 'employee は company がないと無効であること' do
      user = FactoryBot.build(:user, role: :employee, company: nil)
      user.valid?

      expect(user.errors[:company]).to be_present
    end
  end

  describe '#active_for_authentication?' do
    it 'active が true のとき true を返すこと' do
      user = FactoryBot.build(:user, active: true)
      expect(user.active_for_authentication?).to be true
    end

    it 'active が false のとき false を返すこと' do
      user = FactoryBot.build(:user, active: false)
      expect(user.active_for_authentication?).to be false
    end
  end

  describe '#inactive_message' do
    it 'active が false のとき inactive を返すこと' do
      user = FactoryBot.build(:user, active: false)
      expect(user.inactive_message).to eq(:inactive)
    end
  end
end
