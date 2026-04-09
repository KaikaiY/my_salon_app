require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:therapist_invitation) { create(:invitation, :therapist, company: nil) }
  let(:employee_invitation) { create(:invitation, company: create(:company)) }

  describe "GET /users/sign_up" do
    it "有効な招待URLなら登録画面にアクセスできること" do
      get new_user_registration_path, params: { invitation_token: therapist_invitation.token }

      expect(response).to have_http_status(:ok)
    end

    it "無効な招待URLならトップにリダイレクトされること" do
      get new_user_registration_path, params: { invitation_token: "invalid_token" }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /users" do
    it "therapist 招待なら company なしで登録できること" do
      therapist_invitation

      expect do
        post user_registration_path, params: {
          user: {
            name: "テストセラピスト",
            password: "password123",
            password_confirmation: "password123",
            invitation_token: therapist_invitation.token
          }
        }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(new_user_session_path)
      expect(User.last.role).to eq("therapist")
      expect(User.last.company).to be_nil
      expect(User.last.active).to be false
    end

    it "employee 招待なら company 付きで登録できること" do
      employee_invitation
      
      expect do
        post user_registration_path, params: {
          user: {
            name: "テスト利用者",
            password: "password123",
            password_confirmation: "password123",
            invitation_token: employee_invitation.token
          }
        }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(new_user_session_path)
      expect(User.last.role).to eq("employee")
      expect(User.last.company).to eq(employee_invitation.company)
      expect(User.last.active).to be false
    end

    it "登録後は invitation が accepted になること" do
      post user_registration_path, params: {
        user: {
          name: "テストセラピスト",
          password: "password123",
          password_confirmation: "password123",
          invitation_token: therapist_invitation.token
        }
      }

      expect(response).to redirect_to(new_user_session_path)
      expect(therapist_invitation.reload.status).to eq("accepted")
      expect(therapist_invitation.user).to eq(User.last)
      expect(therapist_invitation.accepted_at).to be_present
    end
  end
end
