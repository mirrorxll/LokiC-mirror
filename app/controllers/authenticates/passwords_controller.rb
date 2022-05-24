# frozen_string_literal: true

module Authenticates
  class PasswordsController < AuthenticatesController
    skip_before_action :authenticate_user!

    before_action :find_account_by_email, only: %i[edit create]
    before_action :find_account_by_reset_token, only: %i[update]
    before_action :tab_title, only: %i[new edit]

    def new; end

    def create
      if @account
        @account.generate_token(:reset_password_token)
        @account.update(reset_password_sent_at: DateTime.now)

        AccountMailer.with(account: @account).password_reset.deliver_now

        flash[:success] = { password_reset: 'token has been sent to the email provided' }
        redirect_to password_reset_path(email: params[:email])
      else
        flash.now[:error] = { password_reset: 'account with this email not found' }
        render :new
      end
    end

    def edit
      return if @account

      flash[:error] = { password_reset: 'invalid email' }
      redirect_to send_password_reset_email_path
    end

    def update
      if @account.nil? || @account.reset_password_sent_at < DateTime.now - 2.hours
        flash[:error] = { password_reset: "password reset token isn't valid" }
        redirect_to send_password_reset_email_path
      else
        @account.update(
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          reset_password_token: nil,
          reset_password_sent_at: nil
        )

        if @account.errors.any?
          flash.now[:error] = @account.errors
          render :edit and return
        end

        flash[:success] = { success: 'profile updated' }
        redirect_to sign_in_path
      end
    end

    private

    def tab_title
      @tab_title = 'LokiC :: Password Reset'
    end

    def find_account_by_reset_token
      @account = Account.find_by(reset_password_token: params[:token])
    end
  end
end
