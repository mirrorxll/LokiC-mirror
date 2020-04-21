# frozen_string_literal: true

class Columns < ApplicationRecord
  belongs_to :staging_table

  serialize :list, Hash

  def names_ids
    list.map { |(id, column)| [column[:name], id.to_s] }
  end

  def modify(mod_columns)
    Table.modify_columns(staging_table.name, list, mod_columns)
  end
end
