# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types
  has_and_belongs_to_many :iterations

  def self.story_type_dev_statuses
    where.not(name: ['not started', 'migrated', 'inactive'])
  end

  def self.scrape_task_dev_statuses
    where.not(name: ['not started', 'migrated', 'inactive', 'migrated', 'exported', 'on cron'])
  end

  def self.multi_task_dev_statuses
    where(name: ['not started','in progress','blocked','canceled','done'])
  end
end
