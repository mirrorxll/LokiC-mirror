# frozen_string_literal: true

class Index < ApplicationRecord
  belongs_to :staging_table

  serialize :list, Array

  def add(name, column_ids)
    return if column_ids.empty?

    columns = staging_table.columns.list.select { |id, _col| column_ids.include?(id) }
    Table.add_uniq_index(staging_table.name, name, columns)
  end

  def drop(name)
    return if not_exists?(name)

    Table.drop_uniq_index(staging_table.name, name)
  end

  private

  def not_exists?(name)
    Table.uniq_index_not_exists?(staging_table.name, name)
  end
end
