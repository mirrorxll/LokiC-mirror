# frozen_string_literal: true

class Columns < ApplicationRecord
  serialize :list, Hash

  belongs_to :staging_table

  def modify(mod_columns)
    LokiC::StagingTable.modify_columns(staging_table.name, list, mod_columns)
  end
end
