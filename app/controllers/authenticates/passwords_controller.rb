# frozen_string_literal: true

module Authenticates
  class PasswordsController < AuthenticatesController
    skip_before_action :authenticate_user!

    before_action :find_account_by_email, only: %i[create]
    before_action :find_account_by_reset_token, only: %i[edit update]

    def new; end

    def create
      if @account
        @account.generate_token(:reset_password_token)
        @account.update!(reset_password_sent_at: DateTime.now)

        AccountMailer.with(account: @account).password_reset.deliver_now

        redirect_to sign_in_path, notice: 'Password reset code has been sent to the email provided'
      else
        flash.now[:alert] = 'Account with this email not found'
        render :new
      end
    end

    def edit
      redirect_to send_password_reset_email_path, alert: 'Password reset token has expired' unless @account
    end

    def update
      if @account.nil? || @account.reset_password_sent_at < DateTime.now - 2.hours
        redirect_to send_password_reset_email_path, alert: 'Password reset token has expired'
      elsif params[:password] != params[:password_confirmation]
        flash.now[:alert] = 'Password ard password confirmation must match!'
        render :edit
      else
        @account.update!(
          password: params[:password],
          reset_password_token: nil,
          reset_password_sent_at: nil
        )
        redirect_to sign_in_path, notice: 'Password updated'
      end
    end

    private

    def find_account_by_reset_token
      @account = Account.find_by(reset_password_token: params[:token])
    end
  end
end

