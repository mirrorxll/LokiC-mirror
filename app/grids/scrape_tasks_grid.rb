# frozen_string_literal: true

class ScrapeTasksGrid
  include Datagrid

  # Scope
  scope { ScrapeTask.includes(:frequency).order(id: :desc) }

  # Filters
  filter(:name, :string, header: 'Name(RLIKE)') do |value, scope|
    scope.where('name RLIKE ?', value)
  end

  accounts = Account.joins(:account_types).where(account_types: { name: 'scraper' })
  filter(:scraper, :enum, select: accounts.map { |r| [r.name, r.id] }.sort)

  statuses = [
    ['not started',	1],
    ['in progress',	2],
    ['on cron',	4],
    ['blocked',	5],
    ['canceled', 7],
    ['inactive', 8]
  ]
  filter(:status, :enum, select: statuses)

  frequency = Frequency.pluck(:name, :id)
  filter(:frequency, :enum, select: frequency) do |value, scope|
    scope.where(frequency: { name: value })
  end

  # Columns
  column(:id, header: 'Task Id', mandatory: true, &:id)

  column(:status, order: 'status.name', mandatory: true) do |s_task|
    s_task.status.name
  end

  column(:name, mandatory: true) do |s_task|
    format(s_task.name) { |name| link_to(name, s_task) }
  end

  column(:scrapable, header: 'Scrapable?', mandatory: true) do |s_task|
    if s_task.scrapable.in?([true, false])
      s_task.scrapable ? 'yes' : 'no'
    else
      'not checked'
    end
  end

  column(:scrape_frequency, order: 'frequency.name', mandatory: true) do |s_task|
    s_task.frequency&.name
  end

  column(:scraper, header: 'Assigned to', order: 'scraper&.name', mandatory: true) do |s_task|
    s_task.scraper&.name
  end
end
