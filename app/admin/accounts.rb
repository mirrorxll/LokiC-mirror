# frozen_string_literal: true

ActiveAdmin.register Account do
  permit_params :account_type_id, :email, :first_name, :last_name, :password, :password_confirmation, :slack

  index do
    selectable_column
    column :account_type
    column :name
    column :email
    column :upwork
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :account_type_id, label: 'Account type', as: :select, collection: AccountType.all
      f.input :first_name
      f.input :last_name
      f.inputs for: [:slack] do |s|
        s.input :id, label: 'Slack account', as: :select, collection: SlackAccount.all.map { |slack| [slack.user_name, slack.id] }
      end
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
