# frozen_string_literal: true

module LokiC
  module Queries
    class StageRecord # :nodoc:
      def initialize(story, hash)
        hash[:iteration] = iteration(story)[:number]
        @record = transform(story, hash)
      end

      def insert_dup_on_query
        "insert into `#{@record[:table_name]}` "\
        "(#{@record[:keys]}) values(#{@record[:values]}) "\
        "on duplicate key update #{@record[:updates]};"
      end

      def insert_ignore_query
        "insert ignore into `#{@record[:table_name]}` "\
        "(#{@record[:keys]}) values(#{@record[:values]});"
      end

      private

      def transform(story, hash)
        {
          table_name: story.staging_table.name,
          keys: hash.keys.map { |k| `#{k}` }.join(', '),
          values: hash.values.map { |v| (v.nil? ? 'null' : v.to_s).dump }.join(', '),
          updates: hash.keys.map { |k| "`#{k}` = VALUES(`#{k}`)" }.join(', ')
        }
      end

      def iteration(story)
        if new_iteration?(story)
          story.story_iterations.create
        else
          story.story_iterations.last
        end
      end

      def new_iteration?(story)
        it = story.story_iterations
        count = it.count
        statuses = it.last.attributes.values_at(:populate_status, :create_status)

        count.zero? || statuses.all?(true)
      end
    end
  end
end
