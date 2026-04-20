class InvitationMailer < ApplicationMailer
  def approval_notification(invitation)
    @invitation = invitation
    @user = invitation.user

    mail(
      to: @user.email,
      subject: 'アカウント承認のお知らせ'
    )
  end
end
