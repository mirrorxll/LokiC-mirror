# frozen_string_literal: true

class ScrapeTasksGrid
  include Datagrid

  # Scope
  scope { ScrapeTask.includes(:status, :frequency, :scraper, :general_comment).order(id: :desc) }

  # Filters
  filter(:name, :string, header: 'Name(RLIKE)') do |value, scope|
    scope.where('name RLIKE ?', value)
  end

  accounts = Account.joins(:account_types).where(account_types: { name: 'scraper' })
  filter(:scraper, :enum, select: accounts.map { |r| [r.name, r.id] }.sort)

  statuses = [
    ['not started',	1],
    ['in progress',	2],
    ['blocked',	5],
    ['canceled', 7],
    ['inactive', 8],
    ['done', 9]
  ]
  filter(:status, :enum, select: statuses)

  frequency = Frequency.pluck(:name, :id)
  filter(:frequency, :enum, select: frequency) do |value, scope|
    scope.where(frequencies: { id: value })
  end

  # Columns
  column(:id, header: 'Task Id', mandatory: true, &:id)

  column(:status, order: 'statuses.name', scrape_status: true, html: true, mandatory: true) do |s_task|
    attributes = { class: "bg-#{status_color(s_task.status.name)}" }

    if s_task.status.name.in?(%w[blocked canceled])
      attributes.merge!(
        {
          'data-toggle' => 'tooltip',
          'data-placement' => 'right',
          title: truncate(s_task.status_comment&.body, length: 50)
        }
      )
    end

    content_tag(:div, s_task.status.name, attributes)
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

  column(:scrape_frequency, order: 'frequencies.name', mandatory: true) do |s_task|
    s_task.frequency&.name
  end

  column(:scraper, header: 'Assigned to', order: 'accounts.first_name, accounts.last_name', mandatory: true) do |s_task|
    s_task.scraper&.name
  end

  column(:general_comment, header: 'General comment', order: 'comments.body', mandatory: true) do |s_task|
    format(s_task.general_comment&.body) { |body| truncate(body, length: 50) }
  end
end
