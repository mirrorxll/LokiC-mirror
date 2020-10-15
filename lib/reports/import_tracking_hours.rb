# frozen_string_literal: true

require 'google_drive'

module Reports
  module ImportTrackingHours
    def self.from_google_drive(url, title = nil, range = nil, developer, week)
      session = GoogleDrive::Session.from_config("config/google_drive.json")
      spreadsheet = session.spreadsheet_by_url("#{url}")
      ws = if title.nil?
             spreadsheet.worksheets[0]
           else
             spreadsheet.worksheet_by_title("#{title}")
           end
      # A1-G5
      letters = (range[0].upcase..range[3].upcase).to_a
      (range[1].to_i..range[4].to_i).each do |i|
        TrackingHour.create!(developer: developer,
                             hours: ws["#{letters[0]}#{i}"],
                             type_of_work: TypeOfWork.find_by(name: ws["#{letters[1]}#{i}"]),
                             client: ClientsReport.find_by(name: ws["#{letters[2]}#{i}"]),
                             week: week,
                             date: ws["#{letters[3]}#{i}"],
                             comment: ws["#{letters[4]}#{i}"])
      end
    end
  end
end
