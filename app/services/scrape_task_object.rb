# frozen_string_literal: true

class ScrapeTaskObject
  def self.update(scrape_task, params)
    new(scrape_task, params).send(:update)
  end

  private

  def manager_fields
    %i[
      name gather_task deadline state_id datasource_url
      scrapable data_set_location scraper_id frequency_id
    ]
  end

  def initialize(scrape_task, params)
    @scrape_task = scrape_task
    @params = params
  end
end
