# frozen_string_literal: true

# TableLocation.all.each do |tl|
#   p tl[:table_name]
#   p tl.schema.sql_tables.find_by(name: tl[:table_name])
#   tl.update!(sql_table: tl.schema.sql_tables.find_by(name: tl[:table_name]))
# end

class TableLocation < ApplicationRecord
  serialize :table_columns, Array

  belongs_to :parent, polymorphic: true
  belongs_to :host
  belongs_to :schema
  belongs_to :sql_table, optional: true

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
