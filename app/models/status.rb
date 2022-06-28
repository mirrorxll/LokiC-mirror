# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types
  has_many :accounts

  def self.account_statuses
    ordered_statuses(%w[active deactivated])
  end

  def self.work_request_statuses(created: false, archived: false)
    statuses = ['awaiting task creation', 'in progress', 'done', 'blocked', 'canceled']
    statuses << 'created and in queue' if created
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.factoid_request_statuses(created: true, archived: false)
    statuses = ['in progress', 'done', 'blocked', 'canceled']
    statuses << 'not started' if created
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.multi_task_statuses(archived: false)
    statuses = ['not started', 'in progress', 'blocked', 'canceled', 'done', 'setup done/ongoing recurrent']
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.scrape_task_statuses(manager: false, archived: false)
    statuses = ['in progress', 'on checking', 'done', 'blocked', 'canceled']
    statuses.delete('done') unless manager
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.scrape_task_statuses_for_grid(archived: false)
    statuses = ['in progress', 'on checking', 'done', 'blocked', 'canceled']
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.hle_statuses(archived: false)
    statuses = ['in progress', 'exported', 'on cron','blocked', 'canceled', 'done']
    statuses << 'archived' if archived

    ordered_statuses(statuses)
  end

  def self.ordered_statuses(list)
    where(name: list).order(Arel.sql("FIELD(name, '#{list.join("', '")}')"))
  end
end
