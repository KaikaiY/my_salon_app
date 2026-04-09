require 'rails_helper'

RSpec.describe "TimeSlots", type: :request do
  let(:company) { create(:company) }
  let(:treatment_day) { create(:treatment_day, company: company) }
  let(:time_slot) { create(:time_slot, treatment_day: treatment_day) }

  let(:valid_params) do
    {
      time_slot: {
        start_time: "10:00",
        end_time: "11:00"
      }
    }
  end

  describe "GET /new" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get new_treatment_day_time_slot_path(treatment_day)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get new_treatment_day_time_slot_path(treatment_day)

      expect(response).to have_http_status(:ok) 
    end

    it "会社責任者はアクセスできること" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get new_treatment_day_time_slot_path(treatment_day)
      expect(response).to have_http_status(:ok)
    end

    it "利用者はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      get new_treatment_day_time_slot_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /create" do
    it "管理者は時間枠を作成できること" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.to change(TimeSlot, :count).by(1)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.time_slots.count).to eq(1)
    end

    it "会社責任者は自社の施術日に時間枠を作成できること" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.to change(TimeSlot, :count).by(1)
      expect(treatment_day.time_slots.count).to eq(1)
      expect(treatment_day.time_slots.first.start_time.strftime("%H:%M")).to eq("10:00")
      expect(treatment_day.time_slots.first.end_time.strftime("%H:%M")).to eq("11:00")
      expect(treatment_day.time_slots.first.treatment_day).to eq(treatment_day)
      expect(treatment_day.time_slots.first.reservations.count).to eq(0)

    end

    it "利用者は時間枠を作成できないこと" do
      user = create(:user)
      sign_in user

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /edit" do
    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get edit_treatment_day_time_slot_path(treatment_day, time_slot)

      expect(response).to have_http_status(:ok)
    end

    it "会社責任者はアクセスできること" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      get edit_treatment_day_time_slot_path(treatment_day, time_slot)
      expect(response).to have_http_status(:ok)
    
    end

    it "利用者はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      get edit_treatment_day_time_slot_path(treatment_day, time_slot)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /update" do
    it "管理者は時間枠を更新できること" do
      admin = create(:user, :admin)
      sign_in admin

      patch treatment_day_time_slot_path(treatment_day, time_slot), params: {
        time_slot: {
          start_time: "12:00",
          end_time: "13:00"
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(time_slot.reload.start_time.strftime("%H:%M")).to eq("12:00")
      expect(time_slot.end_time.strftime("%H:%M")).to eq("13:00")
    end

    it "会社責任者は自社の施術日の時間枠を更新できること" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      patch treatment_day_time_slot_path(treatment_day, time_slot), params: {
        time_slot: {
          start_time: "12:00",
          end_time: "13:00"
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(time_slot.reload.start_time.strftime("%H:%M")).to eq("12:00")
      expect(time_slot.end_time.strftime("%H:%M")).to eq("13:00")

    end

    it "利用者は時間枠を更新できないこと" do
      user = create(:user)
      sign_in user

      original_start_time = time_slot.start_time
      original_end_time = time_slot.end_time

      patch treatment_day_time_slot_path(treatment_day, time_slot), params: {
        time_slot: {
          start_time: "12:00",
          end_time: "13:00"
        }
      }

      expect(response).to redirect_to(root_path)
      expect(time_slot.reload.start_time).to eq(original_start_time)
      expect(time_slot.end_time).to eq(original_end_time)
    end
  end
end
