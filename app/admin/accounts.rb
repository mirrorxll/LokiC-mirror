ActiveAdmin.register Account do
  permit_params :account_type_id, :email, :first_name, :last_name, :password, :password_confirmation, :slack
  form do |f|
    f.inputs do
      f.input :email
      f.input :account_type_id, label: 'Account type', as: :select, collection: AccountType.all
      f.input :first_name
      f.input :last_name
      f.inputs for: [:slack] do |s|
        s.input :id, :label => 'Slack account', :as => :select, :collection => SlackAccount.all.map { |slack| [slack.user_name, slack.id] }
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    def create
      super
      slack_id = params[:account][:slack][:id]
      return if slack_id == ''
      slack_account = SlackAccount.find(slack_id)
      slack_account.update(account: @account) if slack_account
    end
  end

end
