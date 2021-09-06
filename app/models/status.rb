# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types

  def self.story_type_dev_statuses
    where.not(name: ['not started', 'migrated', 'inactive', 'deleted', 'on checking'])
  end

  def self.article_type_dev_statuses
    where.not(name: ['not started', 'inactive', 'deleted', 'on checking'])
  end

  def self.scrape_task_dev_statuses
    where(name: ['in progress', 'blocked', 'canceled', 'done', 'on checking'])
  end

  def self.multi_task_dev_statuses
    where(name: ['not started', 'in progress', 'blocked', 'canceled', 'done', 'deleted'])
  end

  def self.multi_task_statuses_for_grid
    where(name: ['not started', 'in progress', 'blocked', 'canceled', 'done'])
  end
end
