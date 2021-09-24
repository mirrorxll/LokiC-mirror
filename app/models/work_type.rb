# frozen_string_literal: true

class WorkType < ApplicationRecord # :nodoc:
  enum work: %i[time_tracking work_request]

  has_and_belongs_to_many :work_requests, join_table: 'types_of_work_work_requests', foreign_key: :type_of_work_id
end
