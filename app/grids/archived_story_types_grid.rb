# frozen_string_literal: true

class ArchivedStoryTypesGrid
  include Datagrid

  # Scope
  scope do
    StoryType.eager_load(
      :status, :frequency,
      :photo_bucket, :developer,
      :clients_publications_tags,
      :clients, :tags, :reminder, :cron_tab,
      :template,
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
  filter(:id, :string, multiple: ',', header: 'Id/Name') do |value, scope|
    scope.where(id: value).or(scope.where('story_types.name like ?', "%#{value.first}%"))
  end
  filter(:developer, :enum, multiple: true, select: Account.ordered.map { |a| [a.name, a.id] })
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
  column(:data_set, mandatory: true, order: 'data_sets.name') do |record|
    record.data_set&.name
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
  column(:last_export, mandatory: true) do |record|
    record.last_export&.to_date
  end
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
