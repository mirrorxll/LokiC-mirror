module StagingTablesHelper
  def data_types
    %i[smallint integer bigint float decimal date
       time datetime string text mediumtext longtext boolean]
  end

  def create_staging_table_link
    link_to('Create staging table',
            story_type_staging_table_path(@story_type),
            method: :post, remote: true,
            class: 'btn btn-sm btn-success d-inline-block mb-3')
  end
end
