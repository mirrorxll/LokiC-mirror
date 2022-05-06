# frozen_string_literal: true

require_relative 'export/lead_factoid_post.rb'

module Factoids
  class ExportToLp
    include Export::LeadFactoidPost

    def initialize
      @lp_client = Limpar::Client.new
    end

    def publish!(iteration, threads_count, chunk)
      factoids_to_export = iteration.articles.not_published
      factoids_to_export = if chunk
                             factoids_to_export.limit(chunk).to_a
                           else
                             factoids_to_export.limit(10_000).to_a
                           end

      article_type       = iteration.article_type
      staging_table_name = article_type.staging_table.name
      st_limpar_columns  = Table.get_limpar_data(staging_table_name)
      main_semaphore     = Mutex.new
      exported           = 0

      threads = Array.new(threads_count) do
        Thread.new do
          loop do
            factoid = main_semaphore.synchronize { factoids_to_export.shift }
            break if factoid.nil?

            limpar_columns = st_limpar_columns.select { |col| col['id'].eql?(factoid.staging_row_id) }
            factoid_post(factoid, limpar_columns.first)
            main_semaphore.synchronize { exported += 1 }
          end
        end
      end
      threads.each(&:join)
      exported = 0 if chunk
      iteration.update!(last_export_batch_size: exported)
    end

    def unpublish!(iteration)
      semaphore = Mutex.new
      factoids  = iteration.articles.published.limit(10_000).to_a

      threads = Array.new(5) do
        Thread.new do
          loop do
            factoid = semaphore.synchronize { factoids.shift }
            break if factoid.nil?

            @lp_client.delete_editorial(factoid.limpar_factoid_id)

            factoid.update!(limpar_factoid_id: nil, exported_at: nil)
          end
        end
      end
      threads.each(&:join)
    end
  end
end
