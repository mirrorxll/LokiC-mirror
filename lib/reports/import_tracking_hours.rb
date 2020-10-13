# frozen_string_literal: true

require 'google_drive'

module Repors
  module ImportTrackingHours
    def self.from_google_drive(url, title = nil, range = nil)
      session = GoogleDrive::Session.from_config("config/google_drive.json")
      spreadsheet = session.spreadsheet_by_url("#{url}")
      ws = if title.nil?
             spreadsheet.worksheets[0]
           else
             spreadsheet.worksheet_by_title('Sheet2')
           end
      # A1-G5
      j = range[1]
      (range[0].to_i..range[3].to_i).each do |i|
        TrackingHour.create!(developer: current_account,
                             hours: ws[i,j],
                             type_of_work: TypeOfWork.find_by(name: ws[i,j+1]),
                             client: ClientsReport.find_by(name: ws[i,j+2]),
                             week: previous_week,
                             date: ws[i,j+3],
                             comment: ws[i,j+4])
      end
    end
  end
end
