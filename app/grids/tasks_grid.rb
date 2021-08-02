# frozen_string_literal: true

class TasksGrid
  include Datagrid

  # Scope
  scope { Task.includes(:tasks_assignments, :creator, :assignment_to) }

  # Filters

  filter(:title, :string, left: true, header: 'Title(RLIKE)') do |value, scope|
    scope.where('title RLIKE ?', value)
  end

  filter(:assignment_to, :enum, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] }) do |value, scope|
    scope.joins(tasks_assignments: [:account]).where('account_id= ?', value)
  end

  filter(:creator, :enum, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:status, :enum, select: Status.where(name: ['not started','in progress','blocked','canceled','done']).pluck(:name, :id).map { |r| [r[0], r[1]] })
  filter(:deadline,:datetime, header: 'Deadline >= ?', multiple: ',')

  # Columns
  column(:id, mandatory: true, header: 'ID')

  column(:status, mandatory: true, order: 'status_id', html: true) do |task|
    attributes = { class: "bg-#{status_color(task.status.name)}" }

    if task.status.name.in?(%w[blocked canceled])
      attributes.merge!(
        {
          'data-toggle' => 'tooltip',
          'data-placement' => 'right',
          title: truncate(task.status_comment&.body, length: 150)
        }
      )
    end

    content_tag(:div, task.status.name, attributes)
  end

  column(:creator, order: 'accounts.first_name, accounts.last_name', mandatory: true) do |task|
    task.creator&.name
  end

  column(:title, mandatory: true) do |task|
    format(task.title) { |title| link_to(title, task) }
  end

  column(:assignment_to, header: 'Assigned to', order: 'accounts.first_name, accounts.last_name', mandatory: true) do |task|
    task.assignment_to.pluck(:first_name, :last_name).map { |r| [r[0] + ' ' + r[1]] }.join(', ')
  end

  column(:deadline, order: 'deadline', mandatory: true) do |task|
    task.deadline
  end
end
