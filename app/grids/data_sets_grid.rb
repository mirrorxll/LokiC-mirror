class DataSetsGrid
  include Datagrid

  # Scope
  scope { DataSet.includes(:status, :state, :sheriff, :responsible_editor, :account, :category, :scrape_task) }

  # Filters
  filter(:status, multiple: true) { |value, scope| scope.where(status: value) }

  filter(:name, :string, header: 'Name(RLIKE)') { |value, scope| scope.where('name RLIKE ?', value) }
  filter(:location, :string, header: 'Location(RLIKE)') { |value, scope| scope.where('location RLIKE ?', value) }
  filter(:comment, :string, header: 'Comment(RLIKE)') { |value, scope| scope.where('comment RLIKE ?', value) }
  filter(:state, :enum, multiple: true, select: State.all.pluck(:short_name, :full_name, :id).map { |r| [r[0] + ' - ' + r[1], r[2]] })
  filter(:category, :enum, multiple: true, select: DataSetCategory.all.order(:name).pluck(:name, :id))

  filter(:scrape_task, :xboolean, left: true) do |value, scope|
    value ? scope.where.not(scrape_task: nil) : scope.where(scrape_task: nil)
  end

  sheriffs = DataSet.where(Arel.sql('sheriff_id IS NOT NULL')).map do |ds|
    sh = ds.sheriff
    [sh.name, sh.id]
  end
  filter(:sheriff, :enum, multiple: true, select: sheriffs)

  responsible_editors = DataSet.where(Arel.sql('responsible_editor_id IS NOT NULL')).map do |ds|
    re = ds.responsible_editor
    [re.name, re.id]
  end
  filter(:responsible_editor, :enum, multiple: true, select: responsible_editors)

  created = DataSet.where(Arel.sql('account_id IS NOT NULL')).map do |ds|
    acc = ds.account
    [acc.name, acc.id]
  end
  filter(:creator, :enum, multiple: true, select: created) do |value, scope|
    scope.where(account: value)
  end

  # filter(:condition1, :dynamic, header: 'Dynamic condition 1')
  # column_names_filter(header: 'Extra Columns', checkboxes: true)

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
  column(:content_counts, mandatory: true) do |record|
    "story types: #{record.story_types.count} | factoid types: #{record.factoid_types.count}".html_safe
  end
  column(:comment, mandatory: true) do |record|
    record.comment ? record.comment.gsub("\n", '<br>').html_safe : ''
  end
end
