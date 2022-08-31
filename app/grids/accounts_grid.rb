# frozen_string_literal: true

class AccountsGrid
  include Datagrid

  # Scope
  scope do
    Account.ordered
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
    ''
  end
  column(:login, mandatory: true) do |account|
    format(account) do
      link_to('login', account_impersonate_path(account), method: :post)
    end
  end
end
