# frozen_string_literal: true

class Columns < ApplicationRecord
  serialize :list, Hash

  belongs_to :staging_table

  def names_ids
    list.map { |(id, column)| [column[:name], id.to_s] }
  end

  def modify(mod_columns)
    LokiC::StagingTable.modify_columns(staging_table.name, list, mod_columns)
  end
end
