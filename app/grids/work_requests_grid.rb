# frozen_string_literal: true

class WorkRequestsGrid
  include Datagrid

  # Scope
  scope { WorkRequest.order(id: :desc) }

  accounts = Account.all.map { |a| [a.name, a.id] }
  filter(:requester, :default, select: accounts) do |value, scope|
    scope.where(requester_id: value)
  end

  # Columns
  column(:priority, mandatory: true) do |req|
    req.priority.name.split(' - ').first
  end

  column(:work_types, mandatory: true) do |req|
    format(req) do |r|
      name = r.work_types.map(&:name).join(', ').truncate(50)
      link_to(name, req)
    end
  end

  column(:clients, mandatory: true) do |req|
    req.clients.map(&:name).join(', ').truncate(50)
  end

  column(:project_order_name, mandatory: true) do |req|
    req.project_order_name.body.truncate(50)
  end

  column(:who_requested, header: 'Who requested?', mandatory: true) do |req|
    req.requester.name
  end
end
