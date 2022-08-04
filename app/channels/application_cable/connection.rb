module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_account

    def connect
      self.current_account = find_verified_account
    end

    private

    def find_verified_account
      if cookies.encrypted[:remember_me] || cookies.encrypted[:_loki_c_session]['auth_token']
        Account.find_by(auth_token: cookies.encrypted[:remember_me] || cookies.encrypted[:_loki_c_session]['auth_token'])
      else
        reject_unauthorized_connection
      end
    end
  end
end
