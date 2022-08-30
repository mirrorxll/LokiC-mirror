# frozen_string_literal: true

class TableLocation < ApplicationRecord
  serialize :table_columns, Array

  belongs_to :parent, polymorphic: true
  belongs_to :host
  belongs_to :schema
  belongs_to :sql_table, optional: true

  scope :existing, -> { joins(:sql_table).where('sql_tables.presence': true) }

  def full_name
    "#{host.name}.#{schema.name}.#{sql_table.name}"
  end

  def host_name
    host.name
  end

  def schema_name
    schema.name
  end

  def table_name
    sql_table.name
  end
end
