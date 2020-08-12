# frozen_string_literal: true

class Columns < ApplicationRecord
  serialize :list, Hash

  belongs_to :staging_table

  # return an array of columns in the format:
  #   [[column_name, column_ids]...]
  # this use in a form for creating a unique index.
  def names_ids
    list.map { |(id, column)| [column[:name], id.to_s] }
  end

  # return an array of column names
  # found by the passed identifiers
  def ids_to_names(ids)
    column_ids = Table.columns_transform(ids, :samples)

    list.each_with_object([]) do |(id, column), names|
      names << column[:name] if column_ids.include?(id)
    end
  end

  def modify(mod_columns)
    Table.modify_columns(staging_table.name, list, mod_columns)
  end
end
