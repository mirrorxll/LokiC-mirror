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
end
