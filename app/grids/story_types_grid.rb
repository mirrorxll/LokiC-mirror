class StoryTypesGrid
  include Datagrid

  # Scope
  scope do
    StoryType.includes(:data_set, :frequency).order(id: :desc)
  end

  # Filters
  # filter(:id, :string, multiple: ',')
  filter(:data_set, :enum, left: true, select: DataSet.all.pluck(:name, :id))
  filter(:developer, :enum, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:frequency, :enum, left: true, select: Frequency.regular.pluck(:name, :id))
  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')
  column_names_filter(header: 'Extra Columns', left: true, checkboxes: true)

  # Columns
  column(:id, mandatory: true, header: 'ID')
  column(:data_set, mandatory: true, order: 'data_sets.name') do |record|
    record.data_set&.name
  end
  column(:developer, mandatory: true, order: 'accounts.first_name, accounts.last_name') do |record|
    record.developer&.name
  end
  column(:name, mandatory: true) do |record|
    format(record.name) do |value|
      link_to value, record
    end
  end
  column(:frequency, mandatory: true, order: 'frequencies.name') do |record|
    record.frequency&.name
  end
  # column(:preparation_doc, mandatory: true) do |record|
  #   format(record.preparation_doc) do |value|
  #     link_to 'Google doc', value unless value.blank?
  #   end
  # end
  # column(:slack_channel, mandatory: true)
  # column(:story_types_count, mandatory: true) do |record|
  #   record.story_types.size
  # end
  # column(:comment, mandatory: true) do |record|
  #   record.comment.gsub("\n",'<br>').html_safe
  # end
  # column(:created_at) do |record|
  #   record.created_at.to_date
  # end
  # column(:updated_at) do |record|
  #   record.updated_at.to_date
  # end

end
