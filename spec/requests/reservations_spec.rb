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

    it "管理者はすべての予約一覧を見られること" do
      admin = create(:user, :admin)
      employee.update!(name: "自社利用者")
      my_reservation = create(:reservation, user: employee, time_slot: time_slot)
      other_company = create(:company)
      other_employee = create(:user, company: other_company, name: "他社利用者")
      other_treatment_day = create(:treatment_day, company: other_company)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      other_reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      sign_in admin

      get reservations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(my_reservation.user.name)
      expect(response.body).to include(other_reservation.user.name)
    end

    it "会社責任者は自社の予約一覧だけを見られること" do
      company_manager = create(:user, :company_manager, company: company)
      employee.update!(name: "自社利用者")
      my_reservation = create(:reservation, user: employee, time_slot: time_slot)
      other_company = create(:company)
      other_employee = create(:user, company: other_company, name: "他社利用者")
      other_treatment_day = create(:treatment_day, company: other_company)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      other_reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      sign_in company_manager

      get reservations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(my_reservation.user.name)
      expect(response.body).not_to include(other_reservation.user.name)
    end

    it "施術者は担当施術日の予約一覧だけを見られること" do
      therapist = create(:user, :therapist)
      treatment_day.update(therapist: therapist)
      employee.update!(name: "担当利用者")
      my_reservation = create(:reservation, user: employee, time_slot: time_slot)
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      other_employee = create(:user, company: other_treatment_day.company, name: "担当外利用者")
      other_reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      sign_in therapist

      get reservations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(my_reservation.user.name)
      expect(response.body).not_to include(other_reservation.user.name)
    end

    it "利用者は自分の予約だけを一覧で見られること" do
      employee.update!(name: "自分の予約利用者")
      my_reservation = create(:reservation, user: employee, time_slot: time_slot)
      other_employee = create(:user, company: company, name: "他人の予約利用者")
      other_time_slot = create(:time_slot, treatment_day: treatment_day, start_time: "12:00", end_time: "13:00")
      other_reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      sign_in employee

      get reservations_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(my_reservation.user.name)
      expect(response.body).not_to include(other_reservation.user.name)
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

    it "管理者は予約画面にアクセスできないこと" do
      admin = create(:user, :admin)
      sign_in admin

      get new_treatment_day_time_slot_reservation_path(treatment_day, time_slot)

      expect(response).to redirect_to(root_path)
    end

    it "会社責任者は予約画面にアクセスできないこと" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get new_treatment_day_time_slot_reservation_path(treatment_day, time_slot)

      expect(response).to redirect_to(root_path)
    end

    it "施術者は予約画面にアクセスできないこと" do
      therapist = create(:user, :therapist)
      sign_in therapist

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

    it "管理者は予約を作成できないこと" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post treatment_day_time_slot_reservations_path(treatment_day, time_slot), params: {
          reservation: {
            note: "管理者予約"
          }
        }
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(root_path)
    end

    it "会社責任者は予約を作成できないこと" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        post treatment_day_time_slot_reservations_path(treatment_day, time_slot), params: {
          reservation: {
            note: "責任者予約"
          }
        }
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(root_path)
    end

    it "施術者は予約を作成できないこと" do
      therapist = create(:user, :therapist)
      sign_in therapist

      expect do
        post treatment_day_time_slot_reservations_path(treatment_day, time_slot), params: {
          reservation: {
            note: "施術者予約"
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
    it "管理者は予約詳細を見られること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot, note: "管理者確認用")
      admin = create(:user, :admin)
      sign_in admin

      get reservation_path(reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("管理者確認用")
    end

    it "会社責任者は自社の予約詳細を見られること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot, note: "自社予約詳細")
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get reservation_path(reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("自社予約詳細")
    end

    it "会社責任者は他社の予約詳細を見られないこと" do
      other_company = create(:company)
      other_employee = create(:user, company: other_company)
      other_treatment_day = create(:treatment_day, company: other_company)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get reservation_path(reservation)

      expect(response).to redirect_to(reservations_path)
    end

    it "施術者は担当施術日の予約詳細を見られること" do
      therapist = create(:user, :therapist)
      treatment_day.update(therapist: therapist)
      reservation = create(:reservation, user: employee, time_slot: time_slot, note: "担当予約詳細")
      sign_in therapist

      get reservation_path(reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("担当予約詳細")
    end

    it "施術者は担当外の予約詳細を見られないこと" do
      therapist = create(:user, :therapist)
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      reservation = create(:reservation, time_slot: other_time_slot)
      sign_in therapist

      get reservation_path(reservation)

      expect(response).to redirect_to(reservations_path)
    end

    it "利用者は自分の予約詳細を見られること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot, note: "自分の予約詳細")
      sign_in employee

      get reservation_path(reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("自分の予約詳細")
    end

    it "利用者は他人の予約詳細を見られないこと" do
      other_employee = create(:user, company: company)
      reservation = create(:reservation, user: other_employee, time_slot: time_slot)
      sign_in employee

      get reservation_path(reservation)

      expect(response).to redirect_to(reservations_path)
    end
  end

  describe "PATCH /cancel" do
    it "管理者は予約をキャンセルできること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot)
      admin = create(:user, :admin)
      sign_in admin

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.reload.status).to eq("cancelled")
    end

    it "会社責任者は自社の予約をキャンセルできること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot)
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.reload.status).to eq("cancelled")
    end

    it "会社責任者は他社の予約をキャンセルできないこと" do
      other_company = create(:company)
      other_employee = create(:user, company: other_company)
      other_treatment_day = create(:treatment_day, company: other_company)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      reservation = create(:reservation, user: other_employee, time_slot: other_time_slot)
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservations_path)
      expect(reservation.reload.status).to eq("reserved")
    end

    it "施術者は担当施術日の予約をキャンセルできること" do
      therapist = create(:user, :therapist)
      treatment_day.update(therapist: therapist)
      reservation = create(:reservation, user: employee, time_slot: time_slot)
      sign_in therapist

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.reload.status).to eq("cancelled")
    end

    it "施術者は担当外の予約をキャンセルできないこと" do
      therapist = create(:user, :therapist)
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      reservation = create(:reservation, time_slot: other_time_slot)
      sign_in therapist

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservations_path)
      expect(reservation.reload.status).to eq("reserved")
    end

    it "利用者は自分の予約をキャンセルできること" do
      reservation = create(:reservation, user: employee, time_slot: time_slot)
      sign_in employee

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.reload.status).to eq("cancelled")
    end

    it "利用者は他人の予約をキャンセルできないこと" do
      other_employee = create(:user, company: company)
      reservation = create(:reservation, user: other_employee, time_slot: time_slot)
      sign_in employee

      expect do
        patch cancel_reservation_path(reservation)
      end.not_to change(Reservation, :count)

      expect(response).to redirect_to(reservations_path)
      expect(reservation.reload.status).to eq("reserved")
    end

    it "キャンセル済みの予約はキャンセルできないこと" do
      reservation = create(:reservation, :cancelled, user: employee, time_slot: time_slot)
      sign_in employee

      patch cancel_reservation_path(reservation)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(reservation.reload.status).to eq("cancelled")
    end

    it "キャンセル済みの予約は予約可能枠に戻ること" do
      create(:reservation, :cancelled, time_slot: time_slot)
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
  end
end
