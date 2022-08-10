# frozen_string_literal: true

class Factoid < ApplicationRecord
  before_create { Table.factoid_set_as_created(staging_table.name, staging_row_id) }
  after_destroy { Table.factoid_set_as_not_created(staging_table.name, staging_row_id) }

  belongs_to :factoid_type
  belongs_to :iteration, class_name: 'FactoidTypeIteration', foreign_key: :factoid_type_iteration_id

  has_one :output, class_name: 'FactoidOutput', dependent: :destroy

  def staging_table
    factoid_type.staging_table
  end

  def body
    output.body
  end

  def lp_factoid_id
    public_send('limpar_factoid_id')
  end

  def link?
    lp_factoid_id.present?
  end

  def lp_link
    return unless link?

    "http://limpar.locallabs.com/editorial_factoids/#{lp_factoid_id}"
  end

  def self.not_published
    where(limpar_factoid_id: nil)
  end

  def self.published
    where.not(limpar_factoid_id: nil)
  end
end
