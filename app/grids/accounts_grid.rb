# frozen_string_literal: true

class AccountsGrid
  include Datagrid

  # Scope
  scope do
    Account.all
  end

  column(:id, mandatory: true, header: 'ID', order: false)
  column(:status, mandatory: true) do |record|
    %w[active deactivated].sample
  end
  column(:name, mandatory: true, &:name)
  column(:roles, mandatory: true) do |record|
    'ddd'
  end
  column(:online, mandatory: true) do |record|
    %w[online offline].sample
  end
  column(:login, mandatory: true) do |record|
    format(record) do
      link_to('login', account_impersonates_path(record), method: :post)
    end
  end
end
