# frozen_string_literal: true

class StoryTypesGrid
  include Datagrid

  # Scope
  scope do
    StoryType.includes(
      :status, :frequency,
      :photo_bucket, :developer,
      :clients_publications_tags,
      :clients, :tags, :reminder,
      data_set: %i[state category]
    ).order(
      'reminders.has_updates DESC',
      'story_types.id desc'
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
    scope.joins(data_set: [:state]).where(data_set: [{ state: data_set_state }])
  end
  filter(:category, :enum, multiple: true, left: true, select: DataSetCategory.all.order(:name).pluck(:name, :id)) do |value, scope|
    data_set_category = DataSetCategory.find(value)
    scope.joins(data_set: [:category]).where(data_set_categories: data_set_category)
  end
  filter(:data_set, :enum, multiple: true, left: true, select: DataSet.all.order(:name).pluck(:name, :id))
  filter(:location, :string, left: true, header: 'Location (like)') do |value, scope|
    scope.joins(:data_set).where('location like ?', "%#{value}%")
  end
  filter(:developer, :enum, multiple: true, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:frequency, :enum, multiple: true, left: true, select: Frequency.pluck(:name, :id))
  filter(:photo_bucket, :enum, multiple: true, left: true, select: PhotoBucket.all.order(:name).pluck(:name, :id))
  filter(:status, :enum, multiple: true, left: true, select: Status.all.pluck(:name, :id)) do |value, scope|
    status = Status.find(value)
    scope.where(status: status)
  end
  filter(:client, :enum, multiple: true, left: true, select: Client.where(hidden_for_story_type: false).order(:name).pluck(:name, :id)) do |value, scope|
    client = Client.find(value)
    scope.joins(clients_publications_tags: [:client]).where(clients: client)
  end
  # filter(:has_updates, :enum, :select => ['Not realized', true, false], left:true) do |value|
  #   not_realized = []
  #   self.each do |story_type|
  #     code = story_type.code.download
  #     not_realized << story_type.id unless code.include?('def check_updates')
  #   end
  #   value == 'Not realized' ? self.where(id: not_realized) : self.joins(:reminder)
  #                                                                .where(:reminders => { :has_updates => value })
  #                                                                .where.not(id: not_realized)
  # end
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
  column(:has_updates, mandatory: true, order: 'reminders.has_updates DESC, story_types.id desc') do |record|
    record.reminder&.has_updates
  end
  column(:client_tags, order: 'frequencies.name', header: 'Client: Tag') do |record|
    str = ''
    record.clients.each_with_index do |client, i|
      str += "<div><strong>#{client.name}</strong>: #{record.tags[i].name}</div>"
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
