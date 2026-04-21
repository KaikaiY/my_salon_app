class InvitationMailer < ApplicationMailer
  def invitation_email(invitation)
    @invitation = invitation
    @signup_url = signup_url_for(invitation)

    mail(
      to: invitation.email,
      subject: '招待URLのお知らせ'
    )
  end

  def approval_notification(invitation)
    @invitation = invitation
    @user = invitation.user

    mail(
      to: @user.email,
      subject: 'アカウント承認のお知らせ'
    )
  end

  private

  def signup_url_for(invitation)
    Rails.application.routes.url_helpers.new_user_registration_url(
      invitation_token: invitation.token,
      host: ENV.fetch('APP_HOST', 'example.com'),
      protocol: ENV.fetch('APP_PROTOCOL', 'https')
    )
  end
end
