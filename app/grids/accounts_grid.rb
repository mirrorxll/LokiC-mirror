# frozen_string_literal: true

class AccountsGrid
  include Datagrid

  attr_accessor :current_account, :true_account

  scope { Account.all }

  # filter
  filter(:name, :string, header: 'Name(RLIKE)') do |value, scope|
    scope.where(
      Arel.sql(
        %|CONCAT(first_name, ' ', last_name) RLIKE "#{value}"|
      )
    )
  end

  filter(:with_slack_account, :xboolean, header: 'With attached slack?') do |value, scope|
    value ? scope.includes(:slack).where.not({ slack_accounts: { account_id: nil } }) : scope.includes(:slack).where({ slack_accounts: { account_id: nil } })
  end

  filter(:roles, :enum, multiple: true, select: AccountRole.pluck(:name, :id) + [nil, nil]) do |values, scope|
    scope.joins(:roles).where(account_roles: { id: values })
  end

  filter(:branches, :enum, multiple: true, select: Branch.pluck(:name, :id)) do |values, scope|
    scope.includes(cards: [:branch]).where(account_cards: { enabled: true }, branches: { id: values })
  end

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
