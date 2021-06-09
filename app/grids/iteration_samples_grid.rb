class IterationSamplesGrid
  include Datagrid
  attr_accessor :client_ids

  scope do
    Sample.includes(:output, publication: :client).order(backdated: :asc, published_at: :asc)
  end

  filter(:output, :string, header: "Headline", left: true) do |value|
    self.joins(:output).where("outputs.headline LIKE ?", "%" + value + "%")
  end
  filter(:pl_staging_story_id, :integer, header: "Pipeline ids", multiple: ',', left: true)

  filter(:client, :enum, select: :client_ids, header: "Client name", left: true)
  filter(:publication, :enum, select: :pubs_select, header: "Publication name", left: true)
  filter(:published_at, :date, multiple: ',', left: true)

  filter(:condition1, :dynamic, left: false, header: 'Dynamic condition 1')
  filter(:condition2, :dynamic, left: false, header: 'Dynamic condition 2')

  #column(:id, header: "id", mandatory: true)
  column(:headline, order: 'outputs.headline, samples.id', mandatory: true)

  column(:pl_staging_story_id, header: "Live", mandatory: true) do |model|
    format(model) do |record|
      record.link? && record.published_at <= Date.today ? link_to('live', record.live_link, target:'_blank') : '---'
    end
  end
  column(:pl_staging_story_id, header: "Pipeline", mandatory: true) do |model|
    format(model) do |record|
      record.link? ? link_to('pipeline', record.pl_link, target:'_blank') : '---'
    end
  end
  column(:id, header: "LokiC", mandatory: true) do |model|
    format(model) do |record|
      link_to('lokic', story_type_iteration_sample_url(@story_type, @iteration, record), target:'_blank')
    end
  end
  column(:client_name, order: 'clients.name, samples.id', mandatory: true)
  column(:publication_name, order: 'publications.name, samples.id', mandatory: true)
  column(:published_at, order: 'published_at, samples.id', mandatory: true)
  column(:backdated, order: 'samples.backdated, samples.id', mandatory: true)

  def pubs_select
    Publication.where(client_id: client_ids.map { |t| t[1] }).pluck(:name, :id).sort
  end
end
