# frozen_string_literal: true

class WorkRequest < ApplicationRecord
  before_create do
    build_project_order_name(subtype: 'project order name')
    build_project_order_details(subtype: 'project order details')
    build_most_worried_details(subtype: 'most worried details')
    build_budget_for_project(subtype: 'budget for project')
    build_status_comment(subtype: 'status comment')

    self.status = Status.find_by(name: 'created and in queue')
  end

  before_update { self.default_sow = !sow.present? }

  before_destroy do
    work_types.clear
    clients.clear
    revenue_types.clear
  end

  belongs_to :requester,            optional: true, class_name: 'Account'
  belongs_to :status,               optional: true
  belongs_to :underwriting_project, optional: true
  belongs_to :priority,             optional: true
  belongs_to :invoice_type,         optional: true
  belongs_to :invoice_frequency,    optional: true

  has_one :project_order_name,    -> { where(subtype: 'project order name') },    dependent: :destroy, as: :commentable, class_name: 'Comment'
  has_one :project_order_details, -> { where(subtype: 'project order details') }, dependent: :destroy, as: :commentable, class_name: 'Comment'
  has_one :most_worried_details,  -> { where(subtype: 'most worried details') },  dependent: :destroy, as: :commentable, class_name: 'Comment'
  has_one :budget_for_project,    -> { where(subtype: 'budget for project') },    dependent: :destroy, as: :commentable, class_name: 'Comment'
  has_one :status_comment,        -> { where(subtype: 'status comment') },        dependent: :destroy, as: :commentable, class_name: 'Comment'

  has_many :projects, class_name: 'Task'

  has_and_belongs_to_many :work_types, join_table: 'types_of_work_work_requests', association_foreign_key: :type_of_work_id, class_name: 'WorkType'
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :revenue_types
end
