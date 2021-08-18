# frozen_string_literal: true

class StoryTypeShownSamplesGrid
  include Datagrid

  # Scope
  scope do
    StoryType.where.not(last_export: nil).order(id: :desc)
             .includes(:developer, :editor, :clients, :tags, data_set: %i[state category])
  end

  # Filters
  accounts = Account.all
  filter(:developer, :enum, select: accounts.map { |r| [r.name, r.id] })

  accounts = Account.joins(:account_types).where(account_types: { name: %i[manager editor] })
  filter(:editor, :enum, select: accounts.map { |r| [r.name, r.id] })

  datasets = DataSet.all.order(:name)
  filter(:data_set, :enum, select: datasets.pluck(:name, :id))

  category = DataSetCategory.all.order(:name)
  filter(:category, :enum, select: category.pluck(:name, :id)) do |value, scope|
    scope.where(data_sets: { data_set_categories: { id: value } })
  end

  states = State.all
  filter(:state, :enum, select: states.map { |state| [state.name, state.id] }) do |value, scope|
    scope.where(data_sets: { states: { id: value } })
  end

  clients = Client.where(hidden: false).order(:name)
  filter(:client, :enum, select: clients.pluck(:name, :id).sort_by(&:first)) do |value, scope|
    scope.where(clients: { id: value })
  end

  # Columns
  column(:id, mandatory: true, header: 'ID')

  column(:name, mandatory: true) do |record|
    format(record.name) do |value|
      link_to value, record
    end
  end

  column(:first_sample, mandatory: true) do |record|
    format(record.first_show_sample) do |sample|
      link_to_if sample&.link?, sample&.pl_story_id, sample&.pl_link, target: '_blank'
    end
  end

  column(:second_sample, mandatory: true) do |record|
    format(record.second_show_sample) do |sample|
      link_to_if sample&.link?, sample&.pl_story_id, sample&.pl_link, target: '_blank'
    end
  end

  column(:third_sample, mandatory: true) do |record|
    format(record.third_show_sample) do |sample|
      link_to_if sample&.link?, sample&.pl_story_id, sample&.pl_link, target: '_blank'
    end
  end
end
