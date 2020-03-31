# frozen_string_literal: true

class Index < ApplicationRecord
  serialize :list, Array

  belongs_to :staging_table

  def add(column_ids)
    return if column_ids.empty?

    columns = staging_table.columns.list.select { |id, _col| column_ids.include?(id) }
    LokiC::StagingTable.add_index(staging_table.name, columns)
  end

  def drop
    return if not_exists?

    ActiveRecord::Migration.remove_index(staging_table.name, name: :story_per_publication)
  end

  private

  def not_exists?
    !ActiveRecord::Migration.index_name_exists?(staging_table.name, :story_per_publication)
  end
end
