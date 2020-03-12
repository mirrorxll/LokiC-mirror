# frozen_string_literal: true

module DataLocationsHelper # :nodoc:
  def domain_name(link, options = {})
    match = link[%r{https?:\/\/([^\/]+)}, 1]
    match ? link_to(match, link, options) : link
  end

  def data_location_keys
    %i[
      source_name
      data_set_location
      data_set_evaluation_document
      scrape_dev_developer_name
      scrape_source
      scrape_frequency
      data_release_frequency
      cron_scraping
      scrape_developer_comments
      source_key_explaining_data
      gather_task
    ]
  end
end
