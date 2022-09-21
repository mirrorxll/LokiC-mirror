# frozen_string_literal: true

class AccountsGrid
  include Datagrid

  attr_accessor :current_account, :true_account

  scope { Account.all.includes(:slack, { cards: [:branch] }) }

  # filter
  filter(:name, :string, header: 'Name(RLIKE)') do |value, scope|
    scope.where(
      Arel.sql(%|CONCAT(first_name, ' ', last_name) RLIKE "#{value}"|)
    )
  end

  all_roles = AccountRole.pluck(:name, :id)
  filter(:roles, :enum, multiple: true, select: all_roles) do |values, scope|
    ids_with_filtered_roles = AccountRole.where(id: values).flat_map { |r| r.accounts.ids }.uniq
    scope.where(id: ids_with_filtered_roles)
  end

  branches = Branch.all.map { |b| [b.name.titleize, b.id] }
  filter(:branches, :enum, multiple: true, select: branches) do |values, scope|
    scope.where(account_cards: { enabled: true }, branches: { id: values })
  end

  filter(:with_slack_account, :xboolean, header: 'With slack account?') do |value, scope|
    where = { slack_accounts: { account_id: nil } }
    value ? scope.where.not(where) : scope.where(where)
  end

  filter(:with_roles, :xboolean, header: 'With roles?') do |value, scope|
    filtered_account_ids =
      if value
        Account.find_each.select { |a| a.roles.present? }
      else
        Account.find_each.select { |a| a.roles.none? }
      end

    scope.where(id: filtered_account_ids)
  end

  filter(:without_branches, :xboolean, header: 'With branches?') do |value, scope|
    filtered_account_ids =
      if value
        Account.find_each.select { |a| a.branch_names.present? }
      else
        Account.find_each.select { |a| a.branch_names.none? }
      end

    scope.where(id: filtered_account_ids)
  end

  # columns
  column(:id, mandatory: true, header: 'ID')

  column(:name, mandatory: true, order: 'first_name, last_name') do |account|
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
    account.branch_access_names.map(&:titleize).join('<br>').html_safe
  end

  column(:last_activity, mandatory: true, order: 'accounts.updated_at') do |account|
    account.updated_at.localtime.strftime('%F %R (%z)')
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
