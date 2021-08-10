# frozen_string_literal: true

class StoryTypeIterationSamplesGrid
  include Datagrid
  attr_accessor :client_ids

  scope do
    Sample.includes(:output, publication: :client).order(backdated: :asc, published_at: :asc)
  end

  filter(:output, :string, header: 'Headline', left: true) do |value|
    joins(:output).where('outputs.headline LIKE ?', '%' + value + '%')
  end

  filter(:client, :enum, select: :client_ids, header: 'Client name', left: true) do |value, scope|
    name = Client.find(value.to_i).name
    if name.eql?('Metric Media')
      mm_pubs = Publication.joins(:client).where('clients.name LIKE :like', like: 'MM -%').pluck(:id).to_a
      scope.where(publication_id: mm_pubs)
    else
      scope.where(client: value)
    end
  end
  filter(:publication, :enum, select: :pubs_select, header: 'Publication name', left: true)
  filter(:published_at, :date, multiple: ',')
  filter(:pl_staging_story_id, :integer, header: 'Pipeline ids', multiple: ',')
  # column(:id, header: "id", mandatory: true)
  column(:headline, order: 'outputs.headline, samples.id', mandatory: true)

  column(:pl_staging_story_id, header: 'Live', mandatory: true) do |model|
    format(model) do |record|
      record.link? && record.published_at <= Date.today ? link_to('live', record.live_link, target: '_blank') : '---'
    end
  end
  column(:pl_staging_story_id, header: 'Pipeline', mandatory: true) do |model|
    format(model) do |record|
      record.link? ? link_to('pipeline', record.pl_link, target: '_blank') : '---'
    end
  end
  column(:id, header: 'LokiC', mandatory: true) do |model|
    format(model) do |record|
      link_to('lokic', story_type_iteration_sample_url(@story_type, @iteration, record), target: '_blank')
    end
  end
  column(:client_name, order: 'clients.name, samples.id', mandatory: true)
  column(:publication_name, order: 'publications.name, samples.id', mandatory: true)
  column(:published_at, order: 'published_at, samples.id', mandatory: true)
  column(:backdated, order: 'samples.backdated, samples.id', mandatory: true)

  def pubs_select
    pubs_arr = []
    client_ids.each do |client| # client_ids - array of clients [["Client name1", 1], ["Client name2", 2]]
      if client[0].eql?('Metric Media')
        mm_pubs = Publication.joins(:client).where('clients.name LIKE :like', like: 'MM -%')
        pubs_arr.push(*mm_pubs)
      else
        client_pubs = Publication.where(client_id: client[1])
        pubs_arr.push(*client_pubs)
      end
    end
    pubs_arr.pluck(:name, :id).uniq.sort
  end
end
