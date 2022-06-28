# frozen_string_literal: true

class MultiTasksGrid
  include Datagrid

  attr_accessor(:current_account)

  # Scope
  scope { Task.includes(:assignments, :creator, :assignment_to, :status, :last_comment).order(id: :desc) }

  # Filters
  filter(:creator_id)
  filter(:title, :string, left: true, header: 'Title(RLIKE)') do |value, scope|
    scope.where('title RLIKE ?', value)
  end

  filter(:description, :string, left: true, header: 'Description(RLIKE)') do |value, scope|
    scope.where('description RLIKE ?', value)
  end

  filter(:assignment_to, :enum, multiple: true, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] }) do |value, scope|
    scope.where('task_assignments.account_id': value)
  end

  filter(:creator, :enum, multiple: true, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:status, :enum, multiple: true, select: Status.where(name: ['not started', 'in progress', 'blocked', 'canceled', 'done']).pluck(:name, :id))
  filter(:deadline, :datetime, header: 'Deadline >= ?', multiple: ',')

  filter(:confirmed, :xboolean, left: true) do |value, scope, grid|
    scope = scope.where('task_assignments.account_id': grid.current_account.id)
    value ? scope.where('task_assignments.confirmed': true) : scope.where.not('task_assignments.confirmed': true)
  end

  # Columns
  column(:id, mandatory: true, header: 'ID')

  column(:status, mandatory: true, order: 'status_id', html: true) do |task|
    attributes = { class: "bg-#{status_color(task.status.name)}" }

    if task.status.name.in?(%w[blocked canceled])
      attributes.merge!(
        {
          'data-toggle' => 'tooltip',
          'data-placement' => 'right',
          title: truncate(task.status_comment, length: 150)
        }
      )
    end
    content_tag(:div, task.status.name, attributes)
  end

  column(:creator, order: 'accounts.first_name, accounts.last_name', mandatory: true) do |task|
    task.creator&.name
  end

  column(:title, mandatory: true) do |task|
    format(task.title) { |title| link_to(title, multi_task_path(task)) }
  end

  column(:assignment_to, header: 'Assigned to', order: 'accounts.first_name, accounts.last_name', mandatory: true) do |task|
    task.assignment_to.pluck(:first_name, :last_name).map { |r| [r[0] + ' ' + r[1]] }.join(', ')
  end

  column(:deadline, order: 'deadline', mandatory: true, &:deadline)

  column(:parent_task_id, header: 'Main task', order: 'parent_task_id', mandatory: true) do |task|
    format("##{task.parent.id}") { |parent_id| link_to parent_id, task.parent } unless task.parent.nil?
  end

  column(:sow, header: 'SOW', mandatory: true, order: 'sow') do |task|
    format("Google doc") { |sow| link_to sow, task.sow } unless task.sow.blank?
  end

  column(:last_comment, header: 'Last comment', order: lambda { |scope|
                                                         scope.joins(:comments).group('tasks.id')
                                                                                   .select('tasks.*, MAX(comments.created_at) as max_created_at')
                                                                                   .order('max_created_at')
                                                       }, mandatory: true, html: true) do |task|
    last_comment = task.last_comment
    if last_comment.nil?
      last_comment
    else
      body = ActionView::Base.full_sanitizer.sanitize(last_comment.body)
      attr = { 'data-toggle' => 'tooltip',
               'data-placement' => 'right',
               title: truncate("#{last_comment.commentator.name}: #{body}", length: 150) }
      content_tag(:div, last_comment.created_at.strftime('%y-%m-%d'), attr)
    end
  end

  column(:created_at, header: 'Created at', mandatory: true) do |task|
    task.created_at.strftime('%F')
  end

  column(:note, header: 'Your note', mandatory: true) do |task, scope|
    note = task.note(scope.current_account)

    ActionView::Base.full_sanitizer.sanitize(note.body).first(10) if !note.nil? && !note.body.nil?
  end
end
