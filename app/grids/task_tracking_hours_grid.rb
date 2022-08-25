# frozen_string_literal: true

class TaskTrackingHoursGrid
  include Datagrid

  # Scope
  scope { MultiTaskTeamWork.done.includes(:multi_task).order(id: :desc) }

  # Filters

  filter(:title, :string, left: true, header: 'Title(RLIKE)') do |value, scope|
    scope.joins(:multi_task).where('title RLIKE ?', value)
  end

  filter(:creator, :enum, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] }) do |value, scope|
    scope.joins(:multi_task).where('tasks.creator_id= ?', value)
  end

  filter(:client, :enum, left: true, select: ClientsReport.all.pluck(:name, :id).map { |r| [r[0], r[1]] }) do |value, scope|
    scope.joins(:multi_task).where('tasks.client_id= ?', value)
  end

  # Columns
  column(:id, mandatory: true, header: 'ID') do |scope|
    scope.task.id
  end

  column(:title, mandatory: true) do |scope|
    format(scope.task.title) { |title| link_to(title, scope.task) }
  end

  column(:creator, mandatory: true) do |scope|
    scope.task.creator&.name
  end

  column(:assignment_to, header: 'Assigned to', mandatory: true) do |scope|
    scope.task.assignment_to.pluck(:first_name, :last_name).map { |r| [r[0] + ' ' + r[1]] }.join(', ')
  end

  column(:client, header: 'Client', mandatory: true) do |scope|
    scope.task.client ? scope.task.client.name : ''
  end

  column(:team_work, mandatory: true) do |scope|
    scope.hours ? "#{ sprintf('%g', scope.sum) } hours" : "$#{MiniLokiC::Formatize::Numbers.add_commas(scope.sum.to_s)}"
  end
end
