# frozen_string_literal: true

class WorkRequest < ApplicationRecord
  before_create do
    build_project_order_name(subtype: 'project order name')
    build_project_order_details(subtype: 'project order details')
    build_most_worried_details(subtype: 'most worried details')
    build_budget_for_project(subtype: 'budget for project')
  end

  belongs_to :underwriting_project
  belongs_to :requested_work_priority

  has_one :project_order_name, -> { where(subtype: 'project order name') }, as: :commentable, class_name: 'Comment'
  has_one :project_order_details, -> { where(subtype: 'project order details') }, as: :commentable, class_name: 'Comment'
  has_one :most_worried_details, -> { where(subtype: 'most worried details') }, as: :commentable, class_name: 'Comment'
  has_one :budget_for_project, -> { where(subtype: 'budget for project') }, as: :commentable, class_name: 'Comment'

  has_and_belongs_to_many :work_types, join_table: 'types_of_work_work_requests', association_foreign_key: :type_of_work_id, class_name: 'WorkType'
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :revenue_types
end
