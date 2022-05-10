# frozen_string_literal: true

class TaskAgencyOpportunityRevenueType < ApplicationRecord # :nodoc:
  self.table_name = 'tasks_agencies_opportunities_rv_ts'

  belongs_to :task
  belongs_to :agency, class_name: 'MainAgency', optional: true
  belongs_to :opportunity, class_name: 'MainOpportunity', optional: true
  belongs_to :revenue_type, class_name: 'RevenueType', optional: true
end