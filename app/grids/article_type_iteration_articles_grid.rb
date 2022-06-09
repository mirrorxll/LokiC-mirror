# frozen_string_literal: true

class ArticleTypeIterationArticlesGrid
  include Datagrid
  attr_accessor :client_ids

  scope do
    Article.includes(:output)
  end

  filter(:output, :string, header: 'Body', left: true) do |value, scope|
    outputs = ArticleOutput.where('body LIKE ?', '%' + value + '%')
    scope.where(id: outputs.ids)
  end
  filter(:exported_at, :datetime, range: true)

  column(:article, header: 'Factoid', mandatory: true) do |rec|
    rec.output.body
  end
  column(:lp_link, header: "Limpar", mandatory: true) do |model|
    link = model.link? ? "http://limpar.locallabs.com/editorial_factoids/#{model.limpar_factoid_id}" : '---'
    format(link) do
      model.link? ? link_to('limpar', model.lp_link, target:'_blank') : '---'
    end
  end
  column(:lokic_link, header: "LokiC", mandatory: true) do |model|
    link = "https://lokic.locallabs.com/article_types/#{model.article_type.id}/iterations/#{model.iteration.id}/articles/#{model.id}"
    format(link) do
      link_to('lokic', article_type_iteration_sample_path(@factoid_type, @iteration, model), target:'_blank')
    end
  end
  column(:exported_at, mandatory: true)
end
