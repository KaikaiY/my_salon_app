require 'rails_helper'

RSpec.describe 'TherapistProfiles', type: :request do
  describe 'GET /index' do
    it '管理者は施術者プロフィール一覧を見られること' do
      admin = create(:user, :admin)
      create(:therapist_profile)
      sign_in admin

      get therapist_profiles_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('施術者プロフィール一覧')
    end

    it '施術者は施術者プロフィール一覧を見られないこと' do
      therapist = create(:user, :therapist)
      sign_in therapist

      get therapist_profiles_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /show' do
    it '管理者は非公開プロフィールを見られること' do
      admin = create(:user, :admin)
      therapist_profile = create(:therapist_profile, specialty: '管理者向け確認用', published: false)
      sign_in admin

      get therapist_profile_path(therapist_profile)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('管理者向け確認用')
    end

    it '施術者本人は非公開プロフィールを見られること' do
      therapist = create(:user, :therapist)
      therapist_profile = create(:therapist_profile, user: therapist, specialty: '本人確認用', published: false)
      sign_in therapist

      get therapist_profile_path(therapist_profile)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('本人確認用')
    end

    it '利用者は公開プロフィールを見られること' do
      employee = create(:user)
      therapist_profile = create(:therapist_profile, :published, specialty: '公開プロフィール')
      sign_in employee

      get therapist_profile_path(therapist_profile)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('公開プロフィール')
    end

    it '利用者は非公開プロフィールを見られないこと' do
      employee = create(:user)
      therapist_profile = create(:therapist_profile, specialty: '非公開プロフィール', published: false)
      sign_in employee

      get therapist_profile_path(therapist_profile)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /new' do
    it '施術者はプロフィール登録画面にアクセスできること' do
      therapist = create(:user, :therapist)
      sign_in therapist

      get new_therapist_profile_path

      expect(response).to have_http_status(:ok)
    end

    it '管理者はプロフィール登録画面にアクセスできないこと' do
      admin = create(:user, :admin)
      sign_in admin

      get new_therapist_profile_path

      expect(response).to redirect_to(root_path)
    end

    it 'プロフィール作成済みの施術者は編集画面に誘導されること' do
      therapist = create(:user, :therapist)
      therapist_profile = create(:therapist_profile, user: therapist)
      sign_in therapist

      get new_therapist_profile_path

      expect(response).to redirect_to(edit_therapist_profile_path(therapist_profile))
    end
  end

  describe 'POST /create' do
    let(:valid_params) do
      {
        therapist_profile: {
          bio: '自己紹介です',
          specialty: '肩こりケア',
          career: '経験3年',
          published: 'true'
        }
      }
    end

    it '施術者は自分のプロフィールを作成できること' do
      therapist = create(:user, :therapist)
      sign_in therapist

      expect do
        post therapist_profiles_path, params: valid_params
      end.to change(TherapistProfile, :count).by(1)

      expect(TherapistProfile.last.user).to eq(therapist)
      expect(response).to redirect_to(therapist_profile_path(TherapistProfile.last))
    end

    it '管理者はプロフィールを作成できないこと' do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post therapist_profiles_path, params: valid_params
      end.not_to change(TherapistProfile, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /edit' do
    it '施術者本人は自分のプロフィール編集画面にアクセスできること' do
      therapist = create(:user, :therapist)
      therapist_profile = create(:therapist_profile, user: therapist)
      sign_in therapist

      get edit_therapist_profile_path(therapist_profile)

      expect(response).to have_http_status(:ok)
    end

    it '施術者は他人のプロフィール編集画面にアクセスできないこと' do
      therapist = create(:user, :therapist)
      other_profile = create(:therapist_profile)
      sign_in therapist

      get edit_therapist_profile_path(other_profile)

      expect(response).to redirect_to(root_path)
    end

    it '管理者はプロフィール編集画面にアクセスできないこと' do
      admin = create(:user, :admin)
      therapist_profile = create(:therapist_profile)
      sign_in admin

      get edit_therapist_profile_path(therapist_profile)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /update' do
    it '施術者本人は自分のプロフィールを更新できること' do
      therapist = create(:user, :therapist)
      therapist_profile = create(:therapist_profile, user: therapist, specialty: '更新前')
      sign_in therapist

      patch therapist_profile_path(therapist_profile), params: {
        therapist_profile: {
          specialty: '更新後',
          bio: '更新後の自己紹介',
          career: '更新後の経歴',
          published: 'true'
        }
      }

      expect(response).to redirect_to(therapist_profile_path(therapist_profile))
      expect(therapist_profile.reload.specialty).to eq('更新後')
      expect(therapist_profile.bio).to eq('更新後の自己紹介')
      expect(therapist_profile.published).to eq(true)
    end

    it '施術者は他人のプロフィールを更新できないこと' do
      therapist = create(:user, :therapist)
      other_profile = create(:therapist_profile, specialty: '更新前')
      sign_in therapist

      patch therapist_profile_path(other_profile), params: {
        therapist_profile: {
          specialty: '更新後'
        }
      }

      expect(response).to redirect_to(root_path)
      expect(other_profile.reload.specialty).to eq('更新前')
    end
  end
end
