# frozen_string_literal: true

class Article < ApplicationRecord
  before_create { Table.article_set_as_created(staging_table.name, staging_row_id) }
  after_destroy { Table.article_set_as_not_created(staging_table.name, staging_row_id) }

  belongs_to :factoid_type
  belongs_to :iteration, class_name: 'FactoidTypeIteration', foreign_key: :factoid_type_iteration_id

  has_one :output, class_name: 'ArticleOutput', dependent: :destroy

  def staging_table
    factoid_type.staging_table
  end

  def body
    output.body
  end

  def lp_article_id
    public_send('limpar_factoid_id')
  end

  def link?
    lp_article_id.present?
  end

  def lp_link
    return unless link?

    "http://limpar.locallabs.com/editorial_factoids/#{lp_article_id}"
  end

  def self.not_published
    where(limpar_factoid_id: nil)
  end

  def self.published
    where.not(limpar_factoid_id: nil)
  end
end
