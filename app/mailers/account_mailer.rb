# frozen_string_literal: true

class AccountMailer < ApplicationMailer
  def password_reset
    @account = params[:account]

    mail to: @account.email, subject: 'LokiC Password Reset'
  end
end
