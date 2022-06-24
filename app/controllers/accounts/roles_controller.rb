# frozen_string_literal: true

module Accounts
  class RolesController < AccountsController
    before_action :find_account

    def show; end

    def edit; end

    def update
      @account.roles.clear

      roles_params.each do |id, state|
        @account.roles << AccountRole.find(id) if state.eql?('1')
      end

      render 'accounts/roles/show'
    end

    private

    def roles_params
      params.require(:roles).permit(
        :'1', :'2', :'3', :'4', :'5', :'6', :'7', :'8', :'9', :'10'
      )
    end
  end
end
