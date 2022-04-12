class PublishedFactoid < ApplicationRecord
  belongs_to :developer, class_name: 'Account'
  belongs_to :article_type
  belongs_to :iteration, class_name: 'ArticleTypeIteration'
end
