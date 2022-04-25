# frozen_string_literal: true

class Agency < ApplicationRecord # :nodoc:
  has_many :opportunities
  has_many :tasks_opportunities, -> { where(multi_tasks: true) }, class_name: 'Opportunity'
end
