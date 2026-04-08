require 'rails_helper'

RSpec.describe "TreatmentDays", type: :request do
  let(:company) { create(:company) }
  let(:therapist) { create(:user, :therapist) }

  let(:valid_params) do
    {
      treatment_day: {
        date: Date.current,
        booking_source: "app",
        status: "pending",
        note: "テストメモ",
        company_id: company.id,
        therapist_id: therapist.id
      }
    }
  end

  describe "GET /index" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get treatment_days_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get treatment_days_path

      expect(response).to have_http_status(:ok)
    end

    it "会社責任者はアクセスできること" do
      manager = create(:user, :company_manager)
      sign_in manager

      get treatment_days_path

      expect(response).to have_http_status(:ok)
    end

    it "利用者はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      get treatment_days_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /new" do
    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get new_treatment_day_path

      expect(response).to have_http_status(:ok)
    end

    it "会社責任者はアクセスできること" do
      manager = create(:user, :company_manager)
      sign_in manager

      get new_treatment_day_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "管理者は施術日を作成できること" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post treatment_days_path, params: valid_params
      end.to change(TreatmentDay, :count).by(1)

      expect(response).to redirect_to(treatment_day_path(TreatmentDay.last))
    end

    it "会社責任者は自社の施術日として作成できること" do
      manager = create(:user, :company_manager)
      sign_in manager

      expect do
        post treatment_days_path, params: valid_params
      end.to change(TreatmentDay, :count).by(1)

      expect(TreatmentDay.last.company).to eq(manager.company)
    end

    it "利用者は施術日を作成できないこと" do
      user = create(:user)
      sign_in user

      expect do
        post treatment_days_path, params: valid_params
      end.not_to change(TreatmentDay, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /update" do
    it "管理者は施術日を更新できること" do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day)
      sign_in admin

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: "phone",
          status: "confirmed",
          note: "更新後メモ",
          company_id: company.id
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.date).to eq(Date.tomorrow)
      expect(treatment_day.booking_source).to eq("phone")
      expect(treatment_day.status).to eq("confirmed")
    end
  end
end
