require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  describe 'GET /' do
    it '未ログイン時はログイン前の表示になること' do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('ログインしていません')
      expect(response.body).to include('ログイン')
    end

    it '管理者には管理者向けメニューが表示されること' do
      admin = create(:user, :admin)
      sign_in admin

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('会社登録ページへ')
      expect(response.body).to include('会社一覧ページへ')
      expect(response.body).to include('招待管理ページへ')
      expect(response.body).to include('施術日一覧ページへ')
      expect(response.body).to include('予約一覧ページへ')
    end

    it '会社責任者には会社責任者向けメニューが表示されること' do
      manager = create(:user, :company_manager)
      sign_in manager

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('施術日一覧ページへ')
      expect(response.body).to include('施術日登録ページへ')
      expect(response.body).to include('予約一覧ページへ')
      expect(response.body).not_to include('会社登録ページへ')
      expect(response.body).not_to include('招待管理ページへ')
    end

    it '施術者には施術者向けメニューが表示されること' do
      therapist = create(:user, :therapist)
      sign_in therapist

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('時間枠一覧ページへ')
      expect(response.body).to include('予約一覧ページへ')
      expect(response.body).not_to include('施術日登録ページへ')
      expect(response.body).not_to include('会社一覧ページへ')
      expect(response.body).not_to include('施術日登録ページへ')
    end

    it '利用者には利用者向けメニューが表示されること' do
      employee = create(:user)
      sign_in employee

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('予約可能枠一覧ページへ')
      expect(response.body).to include('予約一覧ページへ')
      expect(response.body).not_to include('会社一覧ページへ')
      expect(response.body).not_to include('会社一覧ページへ')
      expect(response.body).not_to include('施術日登録ページへ')
    end
  end
end
