# frozen_string_literal: true

class TrackingHour < SecondaryRecord # :nodoc
  belongs_to :developer, optional: true, class_name: 'Account'
  belongs_to :clients_report
  belongs_to :type_of_work
end
