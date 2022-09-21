# frozen_string_literal: true

class FactoidTypesGrid
  include Datagrid

  attr_accessor :current_account, :env

  # Scope
  scope do
    FactoidType.includes(:status, :developer, data_set: %i[state category])
  end

  # Filters
  filter(:id, :string, left: true, multiple: ',')
  filter(:gather_task, :xboolean, left: true) do |value, scope|
    value ? scope.where.not(gather_task: nil) : scope.where(gather_task: nil)
  end
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
  filter(:developer, :enum, left: true, select: Account.ordered.map { |a| [a.name, a.id] })
  filter(:status, :enum, left: true, select: Status.hle_statuses(created: true, migrated: true, inactive: true).pluck(:name, :id)) do |value, scope|
    status = Status.find(value)
    scope.where(status: status)
  end
  filter(:limpar_factoid_id, :string, left: true, multiple: ',', header: 'Limpar ids') do |value, scope, grid|
    factoids = Factoid.where(limpar_factoid_id: value.map(&:strip))
    factoids_factoid_types_ids = factoids.pluck(:factoid_type_id)

    scope.where(id: factoids_factoid_types_ids)
  end
  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')
  column_names_filter(header: 'Extra Columns', left: false, checkboxes: false)

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
    record.data_set&.state&.short_name
  end
  column(:category, order: 'data_set_categories.name') do |record|
    record.data_set&.category&.name
  end
  column(:data_set, mandatory: true, order: 'data_sets.name') do |record|
    format(record.data_set) { |value| link_to value&.name, data_set_path(value) } if record.data_set
  end
  column(:location, order: 'data_sets.location') do |record|
    record.data_set&.location
  end
  column(:developer, mandatory: true, order: 'accounts.first_name, accounts.last_name') do |record|
    record.developer&.name
  end
  column(:name, mandatory: true) do |record|
    format(record.name) do |value|
      link_to value, factoid_type_path(record)
    end
  end
  column(:status, mandatory: true, order: 'statuses.name') do |record|
    record.status.name
  end
  column(:created_at) do |record|
    record.created_at&.to_date
  end
  column(:updated_at) do |record|
    record.updated_at&.to_date
  end
end
