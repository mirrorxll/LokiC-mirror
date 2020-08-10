module StagingTablesHelper
  def data_types
    %i[string text integer float decimal datetime
       timestamp time date boolean]
  end

  def added_columns?(st_table)
    !st_table.columns.list.empty?
  end
end
