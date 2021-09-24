# frozen_string_literal: true

class ExportedStoryTypesGrid
  include Datagrid

  # Scope
  scope { ExportedStoryType.order(id: :desc) }

  # Filters
  filter(:cron_export, :enum, select: [['yes', 1], ['no', 0]]) do |value, scope|
    iteration_ids = StoryTypeIteration.where("name #{value.eql?('1') ? '' : 'NOT'} RLIKE 'CT[0-9]{8}'").ids
    scope.where(iteration_id: iteration_ids)
  end

  accounts = Account.all.map { |r| [r.name, r.id] }.sort
  filter(:developer, :enum, select: accounts)

  accounts = Account.joins(:account_types).where(account_types: { name: %i[manager editor] }).map { |r| [r.name, r.id] }.sort
  filter(:editor, :enum, select: accounts) do |value, scope|
    story_type_ids = StoryType.where(editor_id: value).ids
    scope.where(story_type_id: story_type_ids)
  end

  data_sets = DataSet.all.order(:name).pluck(:name, :id)
  filter(:data_set, :enum, select: data_sets) do |value, scope|
    story_type_ids = StoryType.joins(:data_set).where(data_sets: { id: value }).ids
    scope.where(story_type_id: story_type_ids)
  end

  category = DataSetCategory.all.order(:name)
  filter(:category, :enum, select: category.pluck(:name, :id)) do |value, scope|
    story_type_ids = StoryType.joins(data_set: :category).where(data_sets: { data_set_categories: { id: value } }).ids
    scope.where(story_type_id: story_type_ids)
  end

  states = State.all.map { |state| ["#{state.short_name} - #{state.full_name}", state.id] }
  filter(:state, :enum, select: states) do |value, scope|
    story_type_ids = StoryType.joins(data_set: :state).where(data_sets: { states: { id: value } }).ids
    scope.where(story_type_id: story_type_ids)
  end

  clients = Client.where(hidden_for_story_type: false).order(:name)
  filter(:client, :enum, select: clients.pluck(:name, :id)) do |value, scope|
    story_type_ids = StoryType.joins(clients_publications_tags: :client)
                              .where(story_type_client_publication_tags: { client_id: value }).ids
    scope.where(story_type_id: story_type_ids)
  end

  editor_submitters = PostExportReport.all_editor_reports.map { |r| [r.submitter.name, r.submitter.id] }.uniq
  filter(:reports_submitted_by_editor, :enum, select: editor_submitters) do |value, scope|
    scope.joins(:editor_post_export_report).where(post_export_reports: { submitter_id: value })
  end

  manager_submitters = PostExportReport.all_manager_reports.map { |r| [r.submitter.name, r.submitter.id] }.uniq
  filter(:reports_submitted_by_manager, :enum, select: manager_submitters) do |value, scope|
    scope.joins(:manager_post_export_report).where(post_export_reports: { submitter_id: value })
  end

  # Columns
  column(:id, mandatory: true, header: 'ID') { |record| record.story_type.id }

  column(:name, mandatory: true) do |record|
    format(record.story_type.name) { |value| link_to(value, record.story_type) }
  end

  column(:type_of_export, mandatory: true) { |record| record.first_export ? 'first' : 'follow up' }

  column(:developer, mandatory: true) { |record| record.developer.name }

  column(:export_date, mandatory: true, &:date_export)

  column(:count_of_stories, mandatory: true) { |record| MiniLokiC::Formatize::Numbers.add_commas(record.count_samples) }

  column(:exported_stories, mandatory: true) do |record|
    format(record) do
      link_to('link', stories_story_type_iteration_exports_path(record.story_type, record.iteration), target: '_blank')
    end
  end

  column("editor's report", mandatory: true) do |record|
    format(record.editor_post_export_report) do |report|
      if report
        link_to(
          'report',
          show_editor_report_story_type_iteration_exported_story_types_path(record.story_type, record.iteration),
          remote: true
        )
      end
    end
  end

  column("manager's report", mandatory: true) do |record|
    format(record.manager_post_export_report) do |report|
      if report
        link_to(
          'report',
          show_manager_report_story_type_iteration_exported_story_types_path(record.story_type, record.iteration),
          remote: true
        )
      end
    end
  end

  column('Cron Export?', mandatory: true) { |record| record.iteration.name.match?(/CT\d{8}/) ? 'yes' : 'no' }
end
