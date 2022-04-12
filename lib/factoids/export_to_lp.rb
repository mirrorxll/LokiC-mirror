# frozen_string_literal: true

require_relative 'export/lead_factoid_post.rb'

module Factoids
  class ExportToLp
    include Export::LeadFactoidPost

    def initialize
      @lp_client = Limpar::Client.new
    end

    def publish!(iteration, threads_count)
      factoids_to_export = iteration.articles.to_a
      article_type = iteration.article_type
      main_semaphore = Mutex.new
      exported = 0

      threads = Array.new(threads_count) do
        Thread.new do
          loop do
            factoid = main_semaphore.synchronize { factoids_to_export.shift }
            break if factoid.nil?

            factoid_post(factoid)
            main_semaphore.synchronize { exported += 1 }
          end
        end
      end
      threads.each(&:join)
      iteration.update!(last_export_batch_size: 0)
    end
  end
end
