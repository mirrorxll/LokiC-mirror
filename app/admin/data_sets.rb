ActiveAdmin.register DataSet do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :account_id, :evaluator_id, :src_release_frequency_id, :src_scrape_frequency_id, :name, :src_address, :src_explaining_data, :src_release_frequency_manual, :src_scrape_frequency_manual, :cron_scraping, :location, :evaluation_document, :evaluated, :evaluated_at, :gather_task, :scrape_developer, :comment
  #
  # or
  #
  # permit_params do
  #   permitted = [:account_id, :evaluator_id, :src_release_frequency_id, :src_scrape_frequency_id, :name, :src_address, :src_explaining_data, :src_release_frequency_manual, :src_scrape_frequency_manual, :cron_scraping, :location, :evaluation_document, :evaluated, :evaluated_at, :gather_task, :scrape_developer, :comment]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
