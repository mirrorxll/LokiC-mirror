module StagingTablesHelper
  def data_types
    %i[smallint integer bigint float decimal date
       time datetime string text mediumtext longtext boolean]
  end
end
