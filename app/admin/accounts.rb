# frozen_string_literal: true

ActiveAdmin.register Account do
  permit_params :email, :first_name, :last_name, :password, :password_confirmation, :slack_id, type_ids: []

  index do
    selectable_column
    column :name
    column :email
    column :upwork
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :account_types
      row :email
      row :name
      row :upwork
      row :slack
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      type_ids = AccountType.all.map do |type|
        [type.name, type.id, { checked: object.account_types.include?(type) }]
      end

      f.input :email

      f.input :type_ids,
              label: 'Account Type',
              as: :check_boxes,
              collection: type_ids

      f.input :first_name
      f.input :last_name

      f.input :slack_id,
              label: 'Slack Account',
              as: :select,
              collection: SlackAccount.where(deleted: false).map { |slack| [slack.user_name, slack.id] },
              selected: object.slack&.id

      if object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

  controller do
    def create
      super
      update_additional_info
    end

    def update
      if params[:account][:password].blank?
        %w[password password_confirmation].each { |p| params[:account].delete(p) }
      end

      super
      update_additional_info
    end

    private

    def update_additional_info
      slack_id = permitted_params[:account][:slack_id]
      types = permitted_params[:account][:type_ids].delete_if(&:empty?)

      if slack_id.present?
        slack_account = SlackAccount.find(slack_id)
        slack_account.update!(account: @account)
      else
        @account.slack&.update!(account_id: nil)
      end

      @account.account_types.clear
      types.each { |t| @account.account_types << AccountType.find(t) }
    end
  end
end

