class DataSetsGrid
  include Datagrid

  # Scope
  scope { DataSet.includes(:state, :sheriff, :category, :scrape_task) }

  # Filters
  filter(:scrape_task, :xboolean, left: true) do |value, scope|
    value ? scope.where.not(scrape_task: nil) : scope.where(scrape_task: nil)
  end

  filter(:state, :enum, left: true, select: State.all.pluck(:short_name, :full_name, :id).map { |r| [r[0] + ' - ' + r[1], r[2]] })
  filter(:category, :enum, left: true, select: DataSetCategory.all.order(:name).pluck(:name, :id))
  filter(:sheriff, :enum, left: true, select: Account.all.pluck(:first_name, :last_name, :id).map { |r| [r[0] + ' ' + r[1], r[2]] })
  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')
  column_names_filter(header: 'Extra Columns', left: true, checkboxes: true)

  # Columns
  column(:id, mandatory: true, header: 'ID')
  column(:scrape_task) do |record|
    if record.scrape_task
      format(record.scrape_task) do |task|
        link_to('link', task, target: '_blank')
      end
    end
  end
  column(:state, mandatory: true, order: 'states.short_name') do |record|
    record.state&.short_name
  end
  column(:category, mandatory: true, order: 'data_set_categories.name') do |record|
    record.category&.name
  end
  column(:name, mandatory: true) do |record|
    format(record.name) do |value|
      link_to value, record
    end
  end
  column(:location, mandatory: true)
  column(:sheriff, mandatory: true, order: 'accounts.first_name, accounts.last_name') do |record|
    record.sheriff&.name
  end
  column(:preparation_doc, mandatory: true) do |record|
    format(record.preparation_doc) do |value|
      link_to 'Google doc', value unless value.blank?
    end
  end
  column(:slack_channel, mandatory: true)
  column(:story_types_count, mandatory: true) do |record|
    record.story_types.size
  end
  column(:comment, mandatory: true) do |record|
    record.comment ? record.comment.gsub("\n", '<br>').html_safe : ''
  end
end
