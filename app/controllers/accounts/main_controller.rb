# frozen_string_literal: true

module Accounts
  class MainController < AccountsController
    before_action :generate_grid, only: :index
    before_action :find_account, only: %i[show update]
    before_action :find_slack_account, only: %i[create update]
    before_action :find_status_comment, only: :show

    def index
      @tab_title = 'LokiC :: Accounts'
    end

    def show
      @tab_title = "LokiC :: Account <#{@account.name}>"
    end

    def create
      @account = Account.create(account_params)
      @slack_account&.update(account: @account)
    end

    def update
      @account.update(account_params)
      @account.update(creator: Account.first) unless @account.creator

      if @slack_account
        @slack_account.update(account: @account)
      else
        @account.slack&.update(account: nil)
      end
    end

    private

    def generate_grid
      default =
        case params[:list]
        when 'deactivated'
          { status: Status.find_by(name: 'deactivated') }
        else
          { status: Status.find_by(name: 'active') }
        end

      @grid = AccountsGrid.new(params[:accounts_grid]) do |scope|
        scope.where(default).order(
          Arel.sql(
            "CASE WHEN accounts.id = #{current_account.id} THEN '1' END DESC, CONCAT(first_name, ' ', last_name)"
          )
        )
      end

      @grid.current_account = current_account
      @grid.true_account = true_account
    end

    def account_params
      permitted = params.require(:account).permit(
        :email, :first_name, :last_name,
        :password, :password_confirmation
      ).to_h

      permitted[:creator] = current_account if action_name.eql?('create')
      permitted
    end

    def find_slack_account
      slack_params = params.require(:slack).permit(:id)
      @slack_account = SlackAccount.find_by(slack_params)
    end
  end
end
