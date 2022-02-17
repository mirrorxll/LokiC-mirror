module ScrapeTasks
  class DataSampleSpreadsheetJob < ScrapeTasksJob
    def perform(scrape_task)
      if scrape_task.data_sample
        GoogleDriveClient::Spreadsheet.new(scrape_task.nam)
      else

      end
    end
  end
end
