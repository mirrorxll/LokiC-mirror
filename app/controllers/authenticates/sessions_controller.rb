# frozen_string_literal: true

module Authenticates
  class SessionsController < AuthenticatesController
    skip_before_action :authenticate_user!, except: :destroy

    before_action :find_account_by_email, only: :create

    def new; end

    def create
      if @account.present? && @account.authenticate(params[:password])
        if params[:remember_me].eql?('1')
          cookies.encrypted[:remember_me] = {
            value: @account.auth_token,
            expires: DateTime.now + 1.week
          }
        end
        session[:auth_token] = @account.auth_token

        redirect_to root_path
      else
        flash.now[:alert] = 'Invalid email or password'
        render :new
      end
    end

    def destroy
      session[:auth_token] = nil
      cookies.delete(:remember_me)
      redirect_to sign_in_path, alert: 'Signed out'
    end
  end
end
