# frozen_string_literal: true

class Status < ApplicationRecord
  has_many :story_types
  has_many :accounts

  def self.account_statuses
    ordered_statuses(%w[active deactivated])
  end

  def self.work_request_statuses(created: false, archived: false)
    statuses = created ? ['created and in queue'] : []

    statuses.push('awaiting tasks creation', 'in progress', 'done', 'blocked', 'canceled')
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.factoid_request_statuses(created: false, archived: false)
    statuses = created ? ['created and in queue'] : []

    statuses.push('awaiting templates creation', 'in progress', 'done', 'blocked', 'canceled')
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.multi_task_statuses(created: false, archived: false)
    statuses = created ? ['created and in queue'] : []

    statuses.push('in progress', 'done', 'setup done/ongoing recurrent', 'blocked', 'canceled')
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.scrape_task_statuses(created: false, done: false, archived: false)
    statuses = created ? ['created and in queue'] : []

    statuses.push('in progress', 'on checking')
    statuses.push('done') if done
    statuses.push('blocked', 'canceled')
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.data_set_statuses(archived: false)
    statuses = ['active']
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.hle_statuses(created: false, archived: false)
    statuses = created ? ['created and in queue'] : []

    statuses.push('in progress', 'exported', 'done')
    statuses.push('blocked', 'canceled')
    statuses.push('archived') if archived

    ordered_statuses(statuses)
  end

  def self.ordered_statuses(list)
    where(name: list).order(Arel.sql("FIELD(name, '#{list.join("', '")}')"))
  end
end
