# frozen_string_literal: true

class ProductionRemovalsGrid
  include Datagrid

  # Scope
  scope { ProductionRemoval.order(id: :desc) }

  # Filters
  accounts = Account.all.map { |r| [r.name, r.id] }.sort
  filter(:developer, :enum, select: accounts)

  accounts = Account.joins(:account_types)
                    .where(account_types: { name: %i[manager editor] })
                    .map { |r| [r.name, r.id] }.sort
  filter(:editor, :enum, select: accounts) do |value, scope|
    scope.where(iterations: { story_types: { editors: { id: value } } })
  end

  data_sets = DataSet.all.order(:name).pluck(:name, :id)
  filter(:data_set, :enum, select: data_sets) do |value, scope|
    scope.where(iterations: { story_types: { data_sets: { id: value } } })
  end

  category = DataSetCategory.all.order(:name)
  filter(:category, :enum, select: category.pluck(:name, :id)) do |value, scope|
    scope.where(iterations: { story_types: { data_sets: { data_set_categories: { id: value } } } })
  end

  states = State.all.map { |state| ["#{state.short_name} - #{state.full_name}", state.id] }
  filter(:state, :enum, select: states) do |value, scope|
    scope.where(iterations: { story_types: { data_sets: { states: { id: value } } } })
  end

  clients = Client.where(hidden: false).order(:name)
  filter(:client, :enum, select: clients.pluck(:name, :id)) do |value, scope|
    scope.where(iterations: { story_types: { story_type_client_publication_tags: { client_id: value } } })
  end

  # Columns
  column(:id, mandatory: true, header: 'ID') { |record| record.iteration.story_type.id }

  column(:name, mandatory: true) do |record|
    format(record.iteration.story_type.name) { |value| link_to(value, record.iteration.story_type) }
  end

  column(:developer, mandatory: true) { |record| record.iteration.story_type.developer.name }

  column(:reasons, mandatory: true)
end
