# frozen_string_literal: true

class TrackingHour < SecondaryRecord # :nodoc
  belongs_to :developer, optional: true, class_name: 'Account'
  belongs_to :client, optional: true, class_name: 'ClientsReport'
  belongs_to :type_of_work, optional: true, class_name: 'WorkType'
  belongs_to :week
end
