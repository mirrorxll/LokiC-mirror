# frozen_string_literal: true

class ReportTrackingHour < SecondaryRecord # :nodoc
  belongs_to :account
  belongs_to :clients_report
  belongs_to :type_of_work
end
