# frozen_string_literal: true

class ScrapeTasksGrid
  include Datagrid

  attr_accessor :current_account
  attr_accessor :current_list

  # Scope
  scope do
    ScrapeTask.includes(
      :data_set, :status, :frequency,
      :scraper, :state, :general_comment, :tags
    ).order(id: :desc)
  end

  # Filters
  filter(:name, :string, header: 'Name(RLIKE)') do |value, scope|
    scope.where('name RLIKE ?', value)
  end

  filter(:data_set_location, :string, header: 'Data Location(RLIKE)') do |value, scope|
    p '!' * 100, value
    location_ids = TableLocation.all.to_a.select do |tl|
      p tl.full_name[/#{Regexp.escape(value)}/i]
    end.map(&:id)

    scope.includes(:table_locations).where(table_locations: { id: location_ids })
  end

  filter(:general_comment, :string, header: 'Comment(RLIKE)') do |value, scope|
    ids = Comment.where(commentable_type: 'ScrapeTask', subtype: 'general comment').where('body RLIKE ?', value).ids
    scope.where(comments: { id: ids })
  end

  states = State.all.map { |r| [r.name, r.id] }
  filter(:state, :enum, multiple: true, select: states)

  filter(:creator, :enum, select: :creators, multiple: true)
  def creators
    account_list =
      case current_list
      when 'assigned', 'all', 'archived'
        Account.joins(:created_scrape_tasks).distinct.to_a
      when 'created'
        [current_account]
      end

    account_list.map { |a| [a.name, a.id] }
  end

  accounts = AccountRole.find_by(name: 'Scrape Developer').accounts
  filter(:scraper, :enum, multiple: true, select: accounts.map { |r| [r.name, r.id] }.sort)

  filter(:status, :enum, select: :statuses, multiple: true)
  def statuses
    status_list =
      case current_list
      when 'assigned', 'created', 'all'
        Status.scrape_task_statuses(created: true, done: true)
      when 'archived'
        [Status.find_by(name: 'archived')]
      end

    status_list.map { |s| [s.name, s.id] }
  end

  frequency = Frequency.pluck(:name, :id)
  filter(:frequency, :enum, multiple: true, select: frequency) do |value, scope|
    scope.where(frequencies: { id: value })
  end

  scrape_task_tags = ScrapeTaskTag.order(:name).pluck(:name, :id)
  filter(:tag, :enum, multiple: true, select: scrape_task_tags) do |value, scope|
     scope.where('scrape_task_tags.id': value)
  end

  filter(:with_data_location, :xboolean, header: 'With data location?') do |value, scope|
    scp = scope.includes(:table_locations)
    value ? scp.where.not(table_locations: { id: nil }) : scp.where(table_locations: { id: nil })
  end

  filter(:with_dataset, :xboolean, header: 'With dataset?') do |value, scope|
    value ? scope.where.not(data_sets: { id: nil }) : scope.where(data_sets: { id: nil })
  end

  filter(:with_deadline, :xboolean, header: 'With deadline?') do |value, scope|
    value ? scope.where.not(deadline: nil) : scope.where(deadline: nil)
  end

  scrapable = [['yes', 1], ['no', 0], ['not checked', -1]]
  filter(:scrapable, :enum, multiple: true, header: 'Scrapable?', select: scrapable) do |value, scope|
    scope.where(scrapable: value)
  end

  # Columns
  column(:id, header: 'Id', mandatory: true, &:id)

  column(:state, header: 'State', order: 'states.short_name', mandatory: true) { |s_task| s_task.state&.short_name }

  column(:status, order: 'statuses.name', html: true, mandatory: true) do |s_task|
    attributes = { class: "bg-#{status_color(s_task.status.name)}" }

    if s_task.status.name.in?(%w[blocked canceled])
      attributes.merge!(
        {
          'data-toggle' => 'tooltip',
          'data-placement' => 'right',
          title: truncate(s_task.status_comment&.body, length: 150)
        }
      )
    end

    content_tag(:div, s_task.status.name, attributes)
  end

  column(:name, mandatory: true) do |s_task|
    format(s_task.name) { |name| link_to(name, s_task) }
  end

  column(:tags, header: 'Tag', order: 'scrape_task_tags_task.tag_id', mandatory: true) do |task|
    format(task) do |name|
      name.tags.map do |tag|
        link_to tag.name, url_for(list: @current_list, scrape_tasks_grid: { tag: [tag.id] })
      end.join('<br>').html_safe
    end
  end

  column(:deadline, header: 'Deadline', mandatory: true, &:deadline)

  column(:scrape_frequency, header: 'Frequency', order: 'frequencies.name', mandatory: true) do |s_task|
    s_task.frequency&.name
  end

  column(:scraper, header: 'Dev', order: 'accounts.first_name, accounts.last_name', mandatory: true) do |s_task|
    s_task.scraper&.name
  end

  column(:general_comment, header: 'Comment', order: 'comments.body', mandatory: true) do |s_task|
    format(s_task.general_comment.body) { |body| truncate(ActionView::Base.full_sanitizer.sanitize(body), length: 35) }
  end

  def row_classes(row)
    return 'not-scrapable' if row.scrapable.eql?(false)

    return unless row.deadline

    left_until_dl = (row.deadline - Date.today).to_i

    if left_until_dl.to_i.eql?(0)
      'deadline-1'
    elsif left_until_dl.to_i.between?(-2, -1)
      'deadline-2'
    end
  end
end
