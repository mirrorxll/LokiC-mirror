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

      ranges = range.split('-')
      letters = (ranges.first[0].upcase..ranges.last[0].upcase).to_a
      (ranges.first[1..-1].to_i..ranges.last[1..-1].to_i).each do |i|

        date = Date.parse(ws["#{letters[3]}#{i}"])

        next if date > week.end || date < week.begin

        type_of_work = TypeOfWork.find_by(name: ws["#{letters[1]}#{i}"])
        client_report = ClientsReport.find_by(name: ws["#{letters[2]}#{i}"])
        next if type_of_work.nil? || client_report.nil?

        TrackingHour.create!(developer: developer,
                             hours: ws["#{letters[0]}#{i}"],
                             type_of_work: type_of_work,
                             client: client_report,
                             week: week,
                             date: ws["#{letters[3]}#{i}"],
                             comment: ws["#{letters[4]}#{i}"])
      end
    ensure
      rows_reports = TrackingHour.where(developer: developer, week: week)
      return if rows_reports.empty?
      Reports::HoursAsm.q(rows_reports)
      return rows_reports.order(:date).map do |dev_hours|
        {
          id: dev_hours.id,
          hours: dev_hours.hours,
          type_of_work: TypeOfWork.find(dev_hours.type_of_work_id).name,
          client: ClientsReport.find(dev_hours.client_id).name,
          date: dev_hours.date,
          comment: dev_hours.comment
        }
      end
    end
  end
end
