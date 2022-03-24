# frozen_string_literal: true

class Article < ApplicationRecord
  before_create { Table.article_set_as_created(staging_table.name, staging_row_id) }
  after_destroy { Table.article_set_as_not_created(staging_table.name, staging_row_id) }

  belongs_to :article_type
  belongs_to :iteration, class_name: 'ArticleTypeIteration', foreign_key: :article_type_iteration_id

  has_one :output, class_name: 'ArticleOutput', dependent: :destroy

  def staging_table
    article_type.staging_table
  end
end
