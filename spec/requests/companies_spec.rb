require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  let(:company) { create(:company) }

  let(:valid_params) do
    {
      company: {
        company_name: 'テスト株式会社',
        email: 'test@example.com',
        phone: '0312345678'
      }
    }
  end

  let(:invalid_params) do
    {
      company: {
        company_name: nil,
        email: 'invalid_email',
        phone: 'abc'
      }
    }
  end

  describe 'GET /index' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      get companies_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get companies_path

      expect(response).to have_http_status(:ok)
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      get companies_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /new' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      get new_company_path

      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get new_company_path

      expect(response).to have_http_status(:ok)
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      get new_company_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST /create' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      post companies_path, params: valid_params
      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者は会社が作られること' do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post companies_path, params: valid_params
      end.to change(Company, :count).by(1)

      expect(response).to redirect_to(companies_path)
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      expect do
        post companies_path, params: valid_params
      end.not_to change(Company, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /show' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      get company_path(company)

      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get company_path(company)

      expect(response).to have_http_status(:ok)
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      get company_path(company)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /edit' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      get edit_company_path(company)
      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get edit_company_path(company)

      expect(response).to have_http_status(:ok)
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      get edit_company_path(company)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /update' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      patch company_path(company), params: valid_params
      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者は会社が更新できること' do
      admin = create(:user, :admin)
      sign_in admin

      patch company_path(company), params: {
        company: {
          company_name: '更新後会社名',
          email: 'updated@example.com',
          phone: '09012345678'
        }
      }

      expect(response).to redirect_to(company_path(company))
      expect(company.reload.company_name).to eq('更新後会社名')
      expect(company.reload.email).to eq('updated@example.com')
      expect(company.reload.phone).to eq('09012345678')
    end
    it '管理者以外はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      original_name = company.company_name

      patch company_path(company), params: valid_params

      expect(response).to redirect_to(root_path)
      expect(company.reload.company_name).to eq(original_name)
    end
  end

  describe 'DELETE /destroy' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      delete company_path(company)
      expect(response).to redirect_to(new_user_session_path)
    end
    it '管理者は会社が削除できること' do
      company
      admin = create(:user, :admin)
      sign_in admin

      expect do
        delete company_path(company)
      end.to change(Company, :count).by(-1)

      expect(response).to redirect_to(companies_path)
    end
    it '管理者以外はトップにリダイレクトされること' do
      company
      user = create(:user)
      sign_in user

      expect do
        delete company_path(company)
      end.not_to change(Company, :count)

      expect(response).to redirect_to(root_path)
    end
  end
end
