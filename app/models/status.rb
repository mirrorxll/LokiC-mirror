# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types

  def self.work_request_statuses
    statuses = ['awaiting task creation', 'in progress', 'done', 'blocked', 'canceled']
    where(name: statuses).order("FIELD(name, '#{statuses.join("', '")}')")
  end

  def self.article_type_statuses
    where.not(name: ['not started', 'inactive', 'deleted', 'on checking'])
  end

  def self.story_type_statuses
    where.not(name: ['not started', 'migrated', 'inactive', 'deleted', 'on checking'])
  end

  def self.scrape_task_statuses(manager)
    statuses = ['in progress', 'on checking', 'done', 'blocked', 'canceled']
    statuses.delete('done') unless manager

    where(name: statuses).order("FIELD(name, '#{statuses.join("', '")}')")
  end

  def self.multi_task_statuses
    where(name: ['not started', 'in progress', 'blocked', 'canceled', 'done', 'deleted'])
  end

  def self.multi_task_statuses_for_grid
    where(name: ['not started', 'in progress', 'blocked', 'canceled', 'done'])
  end
end
