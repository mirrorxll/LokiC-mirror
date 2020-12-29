class DataSetsGrid
  include Datagrid

  # Scope
  scope do
    DataSet.includes(:state, :sheriff, :category)
  end

  # Filters
  filter(:id, :string, :multiple => ',')
  # filter(:email, :string)
  # filter(:disabled, :xboolean)
  filter(:state, :enum, :select => State.all.pluck(:short_name, :id))
  # filter(:logins_count, :integer, :range => true, :default => proc { [User.minimum(:logins_count), User.maximum(:logins_count)]})
  # filter(:registered_at, :date, :range => true)
  # filter(:condition, :dynamic, :header => "Dynamic condition")
  column_names_filter(:header => "Extra Columns", checkboxes: true)

  # Columns
  column(:id)
  column(:state, order: 'states.short_name') do |record|
    record.state&.short_name
  end
  column(:category, order: 'data_set_categories.name') do |record|
    record.category&.name
  end
  column(:name) do |record|
    format(record.name) do |value|
      link_to value, record
    end
  end
  column(:location)
  column(:sheriff, order: 'accounts.first_name, accounts.last_name') do |record|
    record.sheriff&.name
  end
  column(:preparation_doc) do |record|
    format(record.preparation_doc) do |value|
      link_to 'Google doc', value unless value.blank?
    end
  end
  column(:slack_channel)
  column(:story_types_count) do |record|
    record.story_types.size
  end
  column(:comment, mandatory: true) do |record|
    record.comment ? record.comment.gsub("\n",'<br>').html_safe : ''
  end
  column(:created_at) do |record|
    record.created_at.to_date
  end
  column(:updated_at) do |record|
    record.updated_at.to_date
  end

end
