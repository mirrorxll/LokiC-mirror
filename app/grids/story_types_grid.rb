class StoryTypesGrid
  include Datagrid

  # Scope
  scope do
    StoryType.includes(:status, :frequency, :photo_bucket, :developer, :clients_publications_tags, :clients, :tags, data_set: %i[state category])
  end

  # Filters
  filter(:id, :string, left: true, multiple: ',')
  filter(:state, :enum, left: true, select: State.all.pluck(:short_name, :full_name, :id).map { |r| [r[0] + ' - ' + r[1], r[2]] }) do |value, scope|
    scope.joins(data_set: [:state]).where(['states.id = ?', value])
  end
  filter(:category, :enum, left: true, select: DataSetCategory.all.order(:name).pluck(:name, :id)) do |value, scope|
    scope.joins(data_set: [:category]).where(['data_set_categories.id = ?', value])
  end
  filter(:data_set, :enum, left: true, select: DataSet.all.order(:name).pluck(:name, :id))
  filter(:location, :string, left: true, header: 'Location (like)') do |value, scope|
    scope.joins(:data_set).where('location like ?', "%#{value}%")
  end
  filter(:developer, :enum, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:frequency, :enum, left: true, select: Frequency.pluck(:name, :id))
  filter(:photo_bucket, :enum, left: true, select: PhotoBucket.all.order(:name).pluck(:name, :id))
  filter(:status, :enum, left: true, select: Status.all.pluck(:name, :id)) do |value, scope|
    status = Status.find(value)
    scope.where(status: status)
  end
  filter(:client, :enum, left: true, select: Client.where(hidden: false).order(:name).pluck(:name, :id)) do |value, scope|
    scope.joins(clients_publications_tags: [:client]).where(['clients.id = ?', value])
  end
  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')
  column_names_filter(header: 'Extra Columns', left: false, checkboxes: false)

  # Columns
  column(:id, mandatory: true, header: 'ID')
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
  column(:status, mandatory: true, order: 'status.name') do |record|
    record.status.name
  end
  column(:last_export, mandatory: true) do |record|
    record.last_export&.to_date
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
