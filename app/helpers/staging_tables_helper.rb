module StagingTablesHelper
  def data_types
    %i[integer float decimal date
       time datetime string text boolean]
  end

  def added_columns?(st_table)
    !st_table.columns.list.empty?
  end
end
