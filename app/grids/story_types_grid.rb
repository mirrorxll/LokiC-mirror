# frozen_string_literal: true

class StoryTypesGrid
  include Datagrid

  attr_accessor :current_account, :env

  # Scope
  scope do
    StoryType.eager_load(
      :status, :frequency,
      :photo_bucket, :developer,
      :clients_publications_tags,
      :clients, :tags, :reminder,
      :cron_tab, :template,
      :exported_story_types,
      # opportunities: [opportunity: :agency],
      data_set: %i[state category]
    ).order(
      Arel.sql("CASE WHEN reminders.check_updates = false AND cron_tabs.enabled = false THEN '1' END DESC,
                CASE WHEN reminders.check_updates = true AND reminders.has_updates = true THEN '2' END DESC,
                CASE WHEN cron_tabs.enabled = true THEN '3' END DESC,
                CASE WHEN reminders.check_updates = true AND reminders.has_updates = false THEN '4' END DESC,
                story_types.id DESC")
    )
  end

  # Filters
  filter(:id, :string, left: true, multiple: ',')

  filter(:gather_task, :xboolean, left: true) do |value, scope|
    value ? scope.where.not(gather_task: nil) : scope.where(gather_task: nil)
  end
  filter(:level_id, :enum, multiple: true, select: Level.all.pluck(:name, :id), left: true)
  filter(:state, :enum, multiple: true, left: true, select: State.all.pluck(:short_name, :full_name, :id).map { |r| [r[0] + ' - ' + r[1], r[2]] }) do |value, scope|
    data_set_state = State.find(value)
    scope.where(data_sets: { state: data_set_state })
  end
  filter(:category, :enum, multiple: true, left: true, select: DataSetCategory.all.order(:name).pluck(:name, :id)) do |value, scope|
    data_set_category = DataSetCategory.find(value)
    scope.where(data_sets: { category: data_set_category })
  end
  filter(:data_set, :enum, multiple: true, left: true, select: DataSet.all.order(:name).pluck(:name, :id))
  filter(:location, :string, left: true, header: 'Location (like)') do |value, scope|
    scope.joins(:data_set).where('location like ?', "%#{value}%")
  end
  filter(:developer, :enum, multiple: true, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:frequency, :enum, multiple: true, left: true, select: Frequency.pluck(:name, :id))
  filter(:photo_bucket, :enum, multiple: true, left: true, select: PhotoBucket.all.order(:name).pluck(:name, :id))
  filter(:status, :enum, multiple: true, left: true, select: Status.hle_statuses.where.not(name: 'archived').pluck(:name, :id)) do |value, scope|
    status = Status.find(value)
    scope.where(status: status)
  end
  filter(:client, :enum, multiple: true, left: true, select: Client.where(hidden_for_story_type: false).order(:name).pluck(:name, :id)) do |value, scope|
    client = Client.find(value)
    scope.where('story_type_client_publication_tags.client_id': client)
  end
  filter(:publication, :enum, multiple: true, left: true, select: Publication.all.pluck(:name, :id)) do |value, scope, grid|
    if grid.only_exported.present?
      stories = Story.where(publication: value)&.pluck(:story_type_id)&.uniq
      scope.where(id: stories)
    else
      publication = Publication.find(value)
      scope.where('story_type_client_publication_tags.publication_id': publication)
    end
  end
  filter(:only_exported, :enum, select: ['Yes (only story types with exports to selected pubs)'], left: true, dummy: true, checkboxes: true)
  filter(:has_updates, :enum, select: ['Not realized', 'Yes', 'No'], left: true) do |value, scope|
    denotations = { 'Yes' => true, 'No' => false }
    if value == 'Not realized'
      scope.where(reminders: { check_updates: false })
    else
      scope.where(reminders: { has_updates: denotations[value] })
           .where.not(cron_tabs: { enabled: true })
           .where.not(reminders: { check_updates: false })
    end
  end
  filter(:revised, :xboolean, left: true) do |value, scope|
    value ? scope.where.not('templates.revision': nil) : scope.where('templates.revision': nil)
  end
  filter(:pipeline_story_id, :string, left: true, multiple: ',', header: 'Pipeline Story ID') do |value, scope, grid|
    stories = Story.where("stories.pl_#{grid.env}_story_id": value)
    stories_story_types_ids = stories.pluck(:story_type_id)

    scope.where(id: stories_story_types_ids)
  end
  # filter(:agency, :enum, multiple: true, select: Agency.all.order(:name).pluck(:name, :id)) do |value, scope|
  #   scope.where('agencies.id': value)
  # end
  # filter(:opportunity, :enum, multiple: true, select: Opportunity.all.order(:name).pluck(:name, :id)) do |value, scope|
  #   scope.where('story_type_opportunities.opportunity_id': value)
  # end
  filter(:first_export, :datetime, range: true, type: 'date') do |value, scope|
    scope.where('exported_story_types.first_export': true)
         .where('exported_story_types.date_export': value.first..value.last)
  end
  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')
  column_names_filter(header: 'Extra Columns', left: false, checkboxes: false)
  dynamic do
    column(:level, preload: :level, header: 'Level') do |record|
      record.level&.name
    end
  end
  # Columns
  column(:id, mandatory: true, header: 'ID')

  column(:gather_task) do |record|
    if record.gather_task
      format(record.gather_task) do |id|
        link_to('link', "https://pipeline.locallabs.com/gather_tasks/#{id}", target: '_blank')
      end
    end
  end

  column(:state, order: 'states.short_name') do |record|
    record.data_set.state&.short_name
  end
  column(:category, order: 'data_set_categories.name') do |record|
    record.data_set.category&.name
  end
  column(:data_set, mandatory: true, order: 'data_sets.name') do |record, scope|
    format(record.data_set) { |value| link_to value&.name, value }
  end
  column(:location, order: 'data_sets.location') do |record|
    record.data_set.location
  end
  column(:developer, mandatory: true, order: 'accounts.first_name, accounts.last_name') do |record|
    record.developer&.name
  end
  column(:name, mandatory: true) do |record|
    format(record.name) do |value|
      link_to value, record
    end
  end
  column(:status, mandatory: true, order: 'statuses.name') do |record|
    record.status.name
  end
  column(:first_export, order: 'exported_story_types.date_export') do |record|
    record.exported_story_types.first_export.first&.date_export
  end
  column(:last_export, mandatory: true) do |record|
    record.last_export&.to_date
  end
  column(:next_export) do |record|
    next_export = record.next_export&.to_date
    if next_export
      frequency = record.frequency&.name
      gap       = %w[daily weekly].include?(frequency) ? 1.week : 1.month
      color     = if next_export >= Date.today
                    ' bg-success'
                  elsif next_export < Date.today && next_export >= Date.today - gap
                    ' bg-warning'
                  else
                    ' bg-danger'
                  end
    end
    next_export ? { date: next_export, color: color } : nil
  end
  column(:time_frame, order: 'max_time_frame') { |record| record.max_time_frame }
  column(:has_updates,
         mandatory: true,
         order: Arel.sql("CASE WHEN reminders.check_updates = false AND cron_tabs.enabled = false THEN '1' END DESC,
                          CASE WHEN reminders.check_updates = true AND reminders.has_updates = true THEN '2' END DESC,
                          CASE WHEN cron_tabs.enabled = true THEN '3' END DESC,
                          CASE WHEN reminders.check_updates = true AND reminders.has_updates = false THEN '4' END DESC,
                          story_types.id DESC"),
         order_desc: Arel.sql("CASE WHEN reminders.check_updates = false AND cron_tabs.enabled = false THEN '1' END,
                               CASE WHEN reminders.check_updates = true AND reminders.has_updates = true THEN '2' END,
                               CASE WHEN cron_tabs.enabled = true THEN '3' END,
                               CASE WHEN reminders.check_updates = true AND reminders.has_updates = false THEN '4' END,
                               story_types.id DESC")) do |record|
    if record.cron_tab&.enabled?
      'on_cron'
    elsif record.reminder&.check_updates == false
      'not_realized'
    else
      record.reminder&.has_updates
    end
  end
  column(:client_tags, order: 'frequencies.name', header: 'Client: Tag') do |record|
    str = ''
    record.clients.each_with_index do |client, i|
      str += "<div><strong>#{client.name}</strong>: #{record.tags[i]&.name}</div>"
    end
    str.html_safe
  end
  column(:frequency, order: 'frequencies.name') do |record|
    record.frequency&.name
  end
  column(:photo_bucket, order: 'photo_buckets.name') do |record|
    record.photo_bucket&.name
  end
  column(:created_at) do |record|
    record.created_at&.to_date
  end
  column(:updated_at) do |record|
    record.updated_at&.to_date
  end
end
