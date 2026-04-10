require 'rails_helper'

RSpec.describe "Reservations", type: :request do
  let(:company) { create(:company) }
  let(:employee) { create(:user, company: company) }
  let(:treatment_day) { create(:treatment_day, company: company) }
  let(:time_slot) { create(:time_slot, treatment_day: treatment_day) }

  describe "GET /index" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get reservations_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "利用者はアクセスできること" do
      sign_in employee

      get reservations_path

      expect(response).to have_http_status(:ok)
    end

    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get reservations_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "利用者は自社の時間枠の予約画面にアクセスできること" do
      sign_in employee

      get new_treatment_day_time_slot_reservation_path(treatment_day, time_slot)

      expect(response).to have_http_status(:ok)
    end

    it "利用者は他社の時間枠の予約画面にアクセスできないこと" do
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      sign_in employee

      get new_treatment_day_time_slot_reservation_path(other_treatment_day, other_time_slot)

      expect(response).to redirect_to(root_path)
    end

    it "会社責任者は予約画面にアクセスできないこと" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get new_treatment_day_time_slot_reservation_path(treatment_day, time_slot)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /create" do
    it "利用者は自社の時間枠を予約できること" do
      sign_in employee

      expect do
        post treatment_day_time_slot_reservations_path(treatment_day, time_slot), params: {
          reservation: {
            note: "肩こりが気になります"
          }
        }
      end.to change(Reservation, :count).by(1)

      reservation = Reservation.last
      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.user).to eq(employee)
      expect(reservation.time_slot).to eq(time_slot)
      expect(reservation.status).to eq("reserved")
      expect(reservation.note).to eq("肩こりが気になります")
    end

    it "利用者は他社の時間枠を予約できないこと" do
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      sign_in employee

      expect do
        post treatment_day_time_slot_reservations_path(other_treatment_day, other_time_slot), params: {
          reservation: {
            note: "予約したいです"
          }
        }
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(root_path)
    end

    it "予約済みの時間枠は予約できないこと" do
      create(:reservation, time_slot: time_slot)
      sign_in employee

      expect do
        post treatment_day_time_slot_reservations_path(treatment_day, time_slot), params: {
          reservation: {
            note: "予約したいです"
          }
        }
      end.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /show" do
    it "利用者は自分の予約詳細を見られること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot)
      sign_in employee

      get reservation_path(reservation)

      expect(response).to have_http_status(:ok)
    end

    it "利用者は他人の予約詳細を見られないこと" do
      other_employee = create(:user, company: company)
      reservation = create(:reservation, user: other_employee, time_slot: time_slot)
      sign_in employee

      get reservation_path(reservation)

      expect(response).to redirect_to(reservations_path)
    end
  end
end
