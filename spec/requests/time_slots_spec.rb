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

  describe "GET /index" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get time_slots_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "利用者は予約可能枠一覧にアクセスできること" do
      user = create(:user, company: company)
      time_slot
      sign_in user

      get time_slots_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("この時間を予約する")
    end

    it "利用者には予約済みの時間枠が表示されないこと" do
      user = create(:user, company: company)
      create(:reservation, time_slot: time_slot)
      sign_in user

      get time_slots_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(time_slot.start_time.strftime("%H:%M"))
    end

    it "利用者には他社の時間枠が表示されないこと" do
      user = create(:user, company: company)
      other_time_slot = create(:time_slot)
      sign_in user

      get time_slots_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(other_time_slot.treatment_day.company.company_name)
    end

    it "利用者には中止された施術日の時間枠が表示されないこと" do
      user = create(:user, company: company)
      treatment_day.update(status: :cancelled)
      time_slot
      sign_in user

      get time_slots_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(time_slot.start_time.strftime("%H:%M"))
    end
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

    it "中止された施術日の時間枠登録画面にはアクセスできないこと" do
      admin = create(:user, :admin)
      treatment_day.update(status: :cancelled)
      sign_in admin

      get new_treatment_day_time_slot_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
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

    it "管理者は20分ごとに時間枠をまとめて作成できること" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post treatment_day_time_slots_path(treatment_day), params: {
          time_slot: {
            start_time: "10:00",
            end_time: "11:00",
            bulk_create: "1"
          }
        }
      end.to change(TimeSlot, :count).by(3)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.time_slots.order(:start_time).map { |slot| slot.start_time.strftime("%H:%M") }).to eq(%w[10:00 10:20 10:40])
      expect(treatment_day.time_slots.order(:start_time).map { |slot| slot.end_time.strftime("%H:%M") }).to eq(%w[10:20 10:40 11:00])
    end

    it "会社責任者は20分ごとに時間枠をまとめて作成できること" do
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        post treatment_day_time_slots_path(treatment_day), params: {
          time_slot: {
            start_time: "13:00",
            end_time: "14:00",
            bulk_create: "1"
          }
        }
      end.to change(TimeSlot, :count).by(3)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.time_slots.order(:start_time).map { |slot| slot.start_time.strftime("%H:%M") }).to eq(%w[13:00 13:20 13:40])
      expect(treatment_day.time_slots.order(:start_time).map { |slot| slot.end_time.strftime("%H:%M") }).to eq(%w[13:20 13:40 14:00])
    end

    it "同じ施術日に重複する時間枠は作成できないこと" do
      admin = create(:user, :admin)
      create(:time_slot, treatment_day: treatment_day, start_time: "10:00", end_time: "11:00")
      sign_in admin

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.not_to change(TimeSlot, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "一括作成で重複する時間枠がある場合は作成できないこと" do
      admin = create(:user, :admin)
      create(:time_slot, treatment_day: treatment_day, start_time: "10:20", end_time: "10:40")
      sign_in admin

      expect do
        post treatment_day_time_slots_path(treatment_day), params: {
          time_slot: {
            start_time: "10:00",
            end_time: "11:00",
            bulk_create: "1"
          }
        }
      end.not_to change(TimeSlot, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "利用者は時間枠を作成できないこと" do
      user = create(:user)
      sign_in user

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(root_path)
    end

    it "中止された施術日の時間枠は作成できないこと" do
      admin = create(:user, :admin)
      treatment_day.update(status: :cancelled)
      sign_in admin

      expect do
        post treatment_day_time_slots_path(treatment_day), params: valid_params
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
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

    it "中止された施術日の時間枠編集画面にはアクセスできないこと" do
      admin = create(:user, :admin)
      treatment_day.update(status: :cancelled)
      sign_in admin

      get edit_treatment_day_time_slot_path(treatment_day, time_slot)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
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

    it "中止された施術日の時間枠は更新できないこと" do
      admin = create(:user, :admin)
      original_start_time = time_slot.start_time
      original_end_time = time_slot.end_time
      treatment_day.update(status: :cancelled)
      sign_in admin

      patch treatment_day_time_slot_path(treatment_day, time_slot), params: {
        time_slot: {
          start_time: "12:00",
          end_time: "13:00"
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(time_slot.reload.start_time).to eq(original_start_time)
      expect(time_slot.end_time).to eq(original_end_time)
    end
  end

  describe "DELETE /destroy" do
    it "管理者は予約履歴がない時間枠を削除できること" do
      admin = create(:user, :admin)
      time_slot
      sign_in admin

      expect do
        delete treatment_day_time_slot_path(treatment_day, time_slot)
      end.to change(TimeSlot, :count).by(-1)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
    end

    it "会社責任者は自社の予約履歴がない時間枠を削除できること" do
      manager = create(:user, :company_manager, company: company)
      time_slot
      sign_in manager

      expect do
        delete treatment_day_time_slot_path(treatment_day, time_slot)
      end.to change(TimeSlot, :count).by(-1)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
    end

    it "会社責任者は他社の時間枠を削除できないこと" do
      other_treatment_day = create(:treatment_day)
      other_time_slot = create(:time_slot, treatment_day: other_treatment_day)
      manager = create(:user, :company_manager, company: company)
      sign_in manager

      expect do
        delete treatment_day_time_slot_path(other_treatment_day, other_time_slot)
      end.not_to change(TimeSlot, :count)
    end

    it "利用者は時間枠を削除できないこと" do
      user = create(:user, company: company)
      time_slot
      sign_in user

      expect do
        delete treatment_day_time_slot_path(treatment_day, time_slot)
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(root_path)
    end

    it "中止された施術日の時間枠は削除できないこと" do
      admin = create(:user, :admin)
      time_slot
      treatment_day.update(status: :cancelled)
      sign_in admin

      expect do
        delete treatment_day_time_slot_path(treatment_day, time_slot)
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
    end

    it "予約履歴がある時間枠は削除できないこと" do
      admin = create(:user, :admin)
      create(:reservation, time_slot: time_slot)
      sign_in admin

      expect do
        delete treatment_day_time_slot_path(treatment_day, time_slot)
      end.not_to change(TimeSlot, :count)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
    end
  end
end
