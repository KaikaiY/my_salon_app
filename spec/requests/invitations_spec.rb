require 'rails_helper'

RSpec.describe "Invitations", type: :request do
  let(:company) { create(:company) }

  let(:valid_params) do
    {
      invitation: {
        email: "invitee@example.com",
        company_id: company.id,
        role: "employee",
        expires_at: 7.days.from_now
      }
    }
  end

  describe "GET /index" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get invitations_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get invitations_path

      expect(response).to have_http_status(:ok)
    end

    it "管理者以外はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      get invitations_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /new" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      get new_invitation_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理者はアクセスできること" do
      admin = create(:user, :admin)
      sign_in admin

      get new_invitation_path

      expect(response).to have_http_status(:ok)
    end

    it "管理者以外はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      get new_invitation_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /create" do
    it "未ログインだとログイン画面にリダイレクトされること" do
      post invitations_path, params: valid_params
      expect(response).to redirect_to(new_user_session_path)
    end
    it "管理者は招待を作られること" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post invitations_path, params: valid_params
      end.to change(Invitation, :count).by(1)

      expect(response).to redirect_to(invitations_path)
    end

    it "管理者は therapist 招待を company なしで作成できること" do
      admin = create(:user, :admin)
      sign_in admin

      expect do
        post invitations_path, params: {
          invitation: {
            email: "therapist@example.com",
            company_id: nil,
            role: "therapist",
            expires_at: 7.days.from_now
          }
        }
      end.to change(Invitation, :count).by(1)

      expect(response).to redirect_to(invitations_path)
      expect(Invitation.last.role).to eq("therapist")
      expect(Invitation.last.company).to be_nil
    end

    it "管理者以外はトップにリダイレクトされること" do
      user = create(:user)
      sign_in user

      expect do
        post invitations_path, params: valid_params
      end.not_to change(Invitation, :count)

      expect(response).to redirect_to(root_path)
    end

  end

  describe "PATCH /approve" do
    it "管理者は承認できること" do
      admin = create(:user, :admin)
      invitation = create(:invitation, :accepted)
      sign_in admin

      patch approve_invitation_path(invitation)

      expect(response).to redirect_to(invitations_path)
      expect(invitation.reload.status).to eq("approved")
      expect(invitation.user.reload.active).to be true
    end
    it "未ログインだとログイン画面にリダイレクトされること" do
      invitation = create(:invitation, :accepted)

      patch approve_invitation_path(invitation)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "管理者以外はトップにリダイレクトされること" do
      user = create(:user)
      invitation = create(:invitation, :accepted)
      sign_in user

      patch approve_invitation_path(invitation)

      expect(response).to redirect_to(root_path)
    end
  end
end
