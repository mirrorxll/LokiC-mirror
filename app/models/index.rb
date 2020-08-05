# frozen_string_literal: true

class Index < ApplicationRecord
  belongs_to :staging_table

  serialize :list, Array

  def add(column_ids)
    return if column_ids.empty?

    columns = staging_table.columns.list.select { |id, _col| column_ids.include?(id) }
    Table.add_uniq_index(staging_table.name, columns)
  rescue ActiveRecord::ActiveRecordError => e
    e.message
  end

  def drop
    return if not_exists?

    Table.drop_uniq_index(staging_table.name)
  end

  private

  def not_exists?
    Table.uniq_index_not_exists?(staging_table.name)
  end
end
