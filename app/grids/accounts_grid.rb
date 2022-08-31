# frozen_string_literal: true

class AccountsGrid
  include Datagrid

  attr_accessor :current_account, :true_account

  # Scope
  scope do
    Account.all
  end

  # filter
  filter(:status_id)

  # columns
  column(:id, mandatory: true, header: 'ID', order: false)

  column(:name, mandatory: true) do |account|
    format(account) { link_to(account.name, account) }
  end

  column(:slack, mandatory: true) do |account|
    format(account.slack_identifier) do |slack_id|
      if slack_id
        link_to(account.slack&.user_name, "https://slack.com/app_redirect?channel=#{slack_id}", target: '_blank')
      else
        '---'
      end
    end
  end

  column(:roles, mandatory: true) do |account|
    account.role_names.join('<br>').html_safe
  end

  column(:branches, mandatory: true) do |account|
    account.branch_names.map(&:titleize).join('<br>').html_safe
  end

  column(:login, mandatory: true) do |account|
    format(account) do
      if account.eql?(true_account)
        '---'
      elsif account.eql?(current_account)
        link_to('[ back to origin ]', account_stop_impersonating_path, method: :delete)
      else
        link_to('[ login ]', account_impersonate_path(account), method: :post)
      end
    end
  end
end
