class PublishedFactoid < ApplicationRecord
  belongs_to :developer
  belongs_to :article_type
  belongs_to :iteration
end
