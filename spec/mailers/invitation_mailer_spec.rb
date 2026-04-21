require 'rails_helper'

RSpec.describe InvitationMailer, type: :mailer do
  describe '#invitation_email' do
    it '招待メールの宛先、件名、招待URLが正しいこと' do
      invitation = create(:invitation, token: 'test-invitation-token')

      mail = described_class.invitation_email(invitation)
      text_body = mail.text_part ? mail.text_part.body.decoded : mail.body.decoded

      expect(mail.to).to eq([invitation.email])
      expect(mail.subject).to eq('招待URLのお知らせ')
      expect(text_body).to include('登録申請を行ってください')
      expect(text_body).to include('test-invitation-token')
      expect(text_body).to include('https://example.com/users/sign_up?invitation_token=test-invitation-token')
    end
  end

  describe '#approval_notification' do
    it '承認メールの宛先、件名、本文が正しいこと' do
      invitation = create(:invitation, :accepted, role: :employee)

      mail = described_class.approval_notification(invitation)
      text_body = mail.text_part ? mail.text_part.body.decoded : mail.body.decoded

      expect(mail.to).to eq([invitation.user.email])
      expect(mail.subject).to eq('アカウント承認のお知らせ')
      expect(text_body).to include("#{invitation.user.name} 様")
      expect(text_body).to include('承認が完了しました')
      expect(text_body).to include('利用者')
    end
  end
end
