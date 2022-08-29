# frozen_string_literal: true

module Accounts
  class MainController < AccountsController
    before_action :generate_grid, only: :index
    before_action :find_account, only: %i[show update]
    before_action :find_slack_account, only: %i[create update]
    before_action :find_status_comment, only: :show

    def index
      @tab_title = 'LokiC :: Accounts'
      @grid.scope { |scope| scope.page(params[:page]).per(30) }
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
      @account.slack.update(account: nil) if @slack_account && @account.slack
      @slack_account&.update(account: @account)
    end

    private

    def generate_grid
      default =
        case params[:list]
        when 'deactivated'
          { status_id: Status.find_by(name: 'deactivated').id }
        else
          { status_id: Status.find_by(name: 'active').id }
        end
      filter_params = params[:accounts_grid] || default

      @grid = AccountsGrid.new(filter_params)
    end

    def account_params
      permitted = params.require(:account).permit(
        :email, :first_name, :last_name,
        :password, :password_confirmation
      ).to_h

      permitted[:creator] = @current_account if action_name.eql?('create')
      permitted
    end

    def find_slack_account
      slack_params = params.require(:slack).permit(:id)
      @slack_account = SlackAccount.find_by(slack_params)
    end
  end
end
