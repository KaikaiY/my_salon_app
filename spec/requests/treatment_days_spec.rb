require 'rails_helper'

RSpec.describe 'TreatmentDays', type: :request do
  let(:company) { create(:company) }
  let(:therapist) { create(:user, :therapist) }

  let(:valid_params) do
    {
      treatment_day: {
        date: Date.current,
        booking_source: 'app',
        status: 'pending',
        note: 'テストメモ',
        company_id: company.id,
        therapist_id: therapist.id
      }
    }
  end

  describe 'GET /index' do
    it '未ログインだとログイン画面にリダイレクトされること' do
      get treatment_days_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get treatment_days_path

      expect(response).to have_http_status(:ok)
    end

    it '会社責任者はアクセスできること' do
      manager = create(:user, :company_manager)
      sign_in manager

      get treatment_days_path

      expect(response).to have_http_status(:ok)
    end

    it '利用者はトップにリダイレクトされること' do
      user = create(:user)
      sign_in user

      get treatment_days_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /new' do
    it '管理者はアクセスできること' do
      admin = create(:user, :admin)
      sign_in admin

      get new_treatment_day_path

      expect(response).to have_http_status(:ok)
    end

    it '会社責任者はアクセスできること' do
      manager = create(:user, :company_manager)
      sign_in manager

      get new_treatment_day_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /show' do
    it '管理者は施術日詳細を見られること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, note: '管理者確認用')
      sign_in admin

      get treatment_day_path(treatment_day)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('管理者確認用')
    end

    it '会社責任者は自社の施術日詳細を見られること' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, company: manager.company, note: '自社施術日詳細')
      sign_in manager

      get treatment_day_path(treatment_day)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('自社施術日詳細')
    end

    it '会社責任者は他社の施術日詳細を見られないこと' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, note: '他社施術日詳細')
      sign_in manager

      get treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end

    it '施術者は施術日詳細を見られないこと' do
      treatment_day = create(:treatment_day, note: '施術日詳細')
      sign_in therapist

      get treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end

    it '利用者は施術日詳細を見られないこと' do
      user = create(:user)
      treatment_day = create(:treatment_day, note: '施術日詳細')
      sign_in user

      get treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /edit' do
    it '管理者は編集画面にアクセスできること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day)
      sign_in admin

      get edit_treatment_day_path(treatment_day)

      expect(response).to have_http_status(:ok)
    end

    it '会社責任者は自社の編集画面にアクセスできること' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, company: manager.company)
      sign_in manager

      get edit_treatment_day_path(treatment_day)

      expect(response).to have_http_status(:ok)
    end

    it '会社責任者は他社の編集画面にアクセスできないこと' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day)
      sign_in manager

      get edit_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end

    it '施術者は編集画面にアクセスできないこと' do
      treatment_day = create(:treatment_day)
      sign_in therapist

      get edit_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end

    it '利用者は編集画面にアクセスできないこと' do
      user = create(:user)
      treatment_day = create(:treatment_day)
      sign_in user

      get edit_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST /create' do
    it '管理者は施術日を作成できること' do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post treatment_days_path, params: valid_params
      end.to change(TreatmentDay, :count).by(1)

      expect(response).to redirect_to(treatment_day_path(TreatmentDay.last))
    end

    it '会社責任者は自社の施術日として作成できること' do
      manager = create(:user, :company_manager)
      sign_in manager

      expect do
        post treatment_days_path, params: valid_params
      end.to change(TreatmentDay, :count).by(1)

      expect(TreatmentDay.last.company).to eq(manager.company)
    end

    it '利用者は施術日を作成できないこと' do
      user = create(:user)
      sign_in user

      expect do
        post treatment_days_path, params: valid_params
      end.not_to change(TreatmentDay, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /update' do
    it '管理者は施術日を更新できること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day)
      sign_in admin

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: 'phone',
          status: 'confirmed',
          note: '更新後メモ',
          company_id: company.id
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.date).to eq(Date.tomorrow)
      expect(treatment_day.booking_source).to eq('phone')
      expect(treatment_day.status).to eq('confirmed')
    end

    it '会社責任者は自社の施術日を更新できること' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, company: manager.company)
      sign_in manager

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: 'phone',
          status: 'confirmed',
          note: '会社責任者更新後メモ',
          company_id: company.id
        }
      }

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.date).to eq(Date.tomorrow)
      expect(treatment_day.booking_source).to eq('phone')
      expect(treatment_day.status).to eq('confirmed')
      expect(treatment_day.note).to eq('会社責任者更新後メモ')
      expect(treatment_day.company).to eq(manager.company)
    end

    it '会社責任者は他社の施術日を更新できないこと' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day)
      original_date = treatment_day.date
      original_booking_source = treatment_day.booking_source
      original_status = treatment_day.status
      sign_in manager

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: 'phone',
          status: 'confirmed',
          note: '更新不可テスト'
        }
      }

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.date).to eq(original_date)
      expect(treatment_day.booking_source).to eq(original_booking_source)
      expect(treatment_day.status).to eq(original_status)
    end

    it '施術者は施術日を更新できないこと' do
      treatment_day = create(:treatment_day)
      original_date = treatment_day.date
      original_booking_source = treatment_day.booking_source
      original_status = treatment_day.status
      sign_in therapist

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: 'phone',
          status: 'confirmed',
          note: '施術者更新不可'
        }
      }

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.date).to eq(original_date)
      expect(treatment_day.booking_source).to eq(original_booking_source)
      expect(treatment_day.status).to eq(original_status)
    end

    it '利用者は施術日を更新できないこと' do
      user = create(:user)
      treatment_day = create(:treatment_day)
      original_date = treatment_day.date
      original_booking_source = treatment_day.booking_source
      original_status = treatment_day.status
      sign_in user

      patch treatment_day_path(treatment_day), params: {
        treatment_day: {
          date: Date.tomorrow,
          booking_source: 'phone',
          status: 'confirmed',
          note: '利用者更新不可'
        }
      }

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.date).to eq(original_date)
      expect(treatment_day.booking_source).to eq(original_booking_source)
      expect(treatment_day.status).to eq(original_status)
    end
  end

  describe 'PATCH /cancel' do
    it '管理者は施術日を中止できること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, status: :confirmed)
      sign_in admin

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('cancelled')
    end

    it '会社責任者は自社の施術日を中止できること' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, company: manager.company, status: :confirmed)
      sign_in manager

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('cancelled')
    end

    it '施術日を中止すると予約中の予約もキャンセルされること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, status: :confirmed)
      time_slot = create(:time_slot, treatment_day: treatment_day)
      reservation = create(:reservation, time_slot: time_slot, status: :reserved)
      sign_in admin

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('cancelled')
      expect(reservation.reload.status).to eq('cancelled')
      expect(time_slot.reload).to be_present
    end

    it '施術日を中止しても完了済みの予約は変更されないこと' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, status: :confirmed)
      time_slot = create(:time_slot, treatment_day: treatment_day)
      reservation = create(:reservation, time_slot: time_slot, status: :completed)
      sign_in admin

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('cancelled')
      expect(reservation.reload.status).to eq('completed')
      expect(time_slot.reload).to be_present
    end

    it '会社責任者は他社の施術日を中止できないこと' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, status: :confirmed)
      sign_in manager

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.status).to eq('confirmed')
    end

    it '利用者は施術日を中止できないこと' do
      user = create(:user)
      treatment_day = create(:treatment_day, status: :confirmed)
      sign_in user

      patch cancel_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.status).to eq('confirmed')
    end
  end

  describe 'PATCH /reopen' do
    it '管理者は中止済みの施術日を再開できること' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, status: :cancelled)
      sign_in admin

      patch reopen_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('pending')
    end

    it '会社責任者は自社の中止済み施術日を再開できること' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, company: manager.company, status: :cancelled)
      sign_in manager

      patch reopen_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('pending')
    end

    it '再開してもキャンセル済み予約は復活しないこと' do
      admin = create(:user, :admin)
      treatment_day = create(:treatment_day, status: :cancelled)
      time_slot = create(:time_slot, treatment_day: treatment_day)
      reservation = create(:reservation, :cancelled, time_slot: time_slot)
      sign_in admin

      patch reopen_treatment_day_path(treatment_day)

      expect(response).to redirect_to(treatment_day_path(treatment_day))
      expect(treatment_day.reload.status).to eq('pending')
      expect(reservation.reload.status).to eq('cancelled')
    end

    it '会社責任者は他社の施術日を再開できないこと' do
      manager = create(:user, :company_manager)
      treatment_day = create(:treatment_day, status: :cancelled)
      sign_in manager

      patch reopen_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.status).to eq('cancelled')
    end

    it '利用者は施術日を再開できないこと' do
      user = create(:user)
      treatment_day = create(:treatment_day, status: :cancelled)
      sign_in user

      patch reopen_treatment_day_path(treatment_day)

      expect(response).to redirect_to(root_path)
      expect(treatment_day.reload.status).to eq('cancelled')
    end
  end
end
