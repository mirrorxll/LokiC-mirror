# frozen_string_literal: true

module MiniLokiC
  module Story
    module Creation
      module Iteration
        class StoryIteration # :nodoc:
          attr_reader :last

          def initialize(staging_table)
            @staging_table = staging_table
            @db05 = MiniLokiC::Connect::Mysql2.new(host: DB05)
            @db05.query('use loki_storycreator;')
            @last = last_iteration
          end

          def create
            @db05.query(insert_query)
            @db05.last_id
          end

          def update_status
            query = %(update hyperlocal_stories_v2__story_iterations
              set status = true
              where id = #{@last['id']};)

            @db05.query(query)
          end

          def close_connection
            @db05.client.close
          end

          private

          def last_iteration
            query = %(select *
              from hyperlocal_stories_v2__story_iterations
              where staging_table = '#{@staging_table}'
              order by iteration desc limit 1;)

            @db05.client.query(query).first
          end

          def insert_query
            iteration = @last.nil? ? 1 : (@last['iteration'] + 1)

            %|insert into hyperlocal_stories_v2__story_iterations (
                staging_table,
                iteration
              ) values (
                '#{@staging_table}',
                #{iteration}
              );|
          end
        end
      end
    end
  end
end
