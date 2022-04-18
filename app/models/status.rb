# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types

  def self.work_request_statuses
    ordered_statuses(
      [
        'awaiting task creation',
        'in progress', 'done',
        'blocked', 'canceled'
      ]
    )
  end

  def self.multi_task_statuses
    ordered_statuses(
      [
        'not started', 'in progress',
        'blocked', 'canceled', 'done',
        'deleted', 'setup done/ongoing recurrent'
      ]
    )
  end

  def self.multi_task_statuses_for_grid
    ordered_statuses(
      [
        'not started', 'in progress',
        'blocked', 'canceled', 'done',
        'setup done/ongoing recurrent'
      ]
    )
  end

  def self.scrape_task_statuses(manager = false)
    list = ['in progress', 'on checking', 'done', 'blocked', 'canceled']
    list.delete('done') unless manager

    ordered_statuses(list)
  end

  def self.scrape_task_statuses_for_grid
    ordered_statuses(
      [
        'in progress', 'on checking',
        'done', 'blocked', 'canceled'
      ]
    )
  end

  def self.hle_statuses
    ordered_statuses(
      [
        'in progress', 'exported',
        'on cron', 'blocked',
        'canceled', 'done',
        'archived'
      ]
    )
  end

  def self.ordered_statuses(list)
    where(name: list).order(Arel.sql("FIELD(name, '#{list.join("', '")}')"))
  end
end
