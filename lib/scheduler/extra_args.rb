# frozen_string_literal: true

module Scheduler
  module ExtraArgs
    def self.stage_ids(staging_table, arg)
      query = "SELECT id FROM `#{staging_table}` WHERE #{arg};"
      ActiveRecord::Base.connection.exec_query(query).to_a.map { |x| x['id'] }
    end
  end
end
