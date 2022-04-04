# frozen_string_literal: true

class ArticleTypeIterationArticlesGrid
  include Datagrid
  attr_accessor :client_ids

  scope do
    Article.includes(:output)
  end

  filter(:output, :string, header: 'Body', left: true) do |value|
    where('outputs.headline LIKE ?', '%' + value + '%')
  end

  column(:article, mandatory: true) do |rec|
    rec.output.body
  end
  column(:lp_link, header: "Limpar", mandatory: true) do |model|
    link = model.link? ? "https://pipeline.locallabs.com/stories/#{model.limpar_factoid_id}" : '---'
    format(link) do
      model.link? ? link_to('limpar', model.limpar_factoid_id, target:'_blank') : '---'
    end
  end
end
