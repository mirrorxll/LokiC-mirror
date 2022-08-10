# frozen_string_literal: true

require_relative 'export/lead_factoid_post.rb'

module Factoids
  class ExportToLp
    include Export::LeadFactoidPost

    def publish!(iteration, threads_count, chunk)
      factoids_to_export = iteration.factoids.not_published
      factoids_to_export = if chunk
                             factoids_to_export.limit(chunk).to_a
                           else
                             factoids_to_export.limit(10_000).to_a
                           end

      factoid_type       = iteration.factoid_type
      staging_table_name = factoid_type.staging_table.name
      st_limpar_columns  = Table.get_limpar_data(staging_table_name)

      raise StandardError, 'Check correctness of data in the staging table!' unless st_data_validation(st_limpar_columns)

      main_semaphore     = Mutex.new
      exported           = 0
      has_error          = false

      threads = Array.new(threads_count) do
        Thread.new do
          lp_client = Limpar::Client.new
          loop do
            factoid = main_semaphore.synchronize { factoids_to_export.shift }
            break if factoid.nil?

            limpar_columns = st_limpar_columns.select { |col| col['id'].eql?(factoid.staging_row_id) }
          begin
            factoid_post(factoid, limpar_columns.first, lp_client)
          rescue Faraday::UnprocessableEntityError => e
            has_error = true
            message   = prepare_error_message(factoid, e)

            raise StandardError, message
          end
            break if has_error

            main_semaphore.synchronize { exported += 1 }
          end
        end
      end
      threads.each(&:join)
      exported = 0 if chunk
      iteration.update!(last_export_batch_size: exported)
    end

    def unpublish!(iteration, factoid_ids = nil)
      semaphore = Mutex.new
      factoids  = if factoid_ids
                    iteration.factoids.published.where(limpar_factoid_id: factoid_ids).limit(10_000).to_a
                  else
                    iteration.factoids.published.limit(10_000).to_a
                  end

      threads = Array.new(5) do
        Thread.new do
          lp_client = Limpar::Client.new
          loop do
            factoid = semaphore.synchronize { factoids.shift }
            break if factoid.nil?
          # begin
          #   lp_client.delete_editorial(factoid.limpar_factoid_id)
          # rescue Faraday::ResourceNotFound
          #   true
          # end
            if factoid_ids
              factoid.destroy
            else
              factoid.update!(limpar_factoid_id: nil, exported_at: nil)
            end
          end
        end
      end
      threads.each(&:join)
    end

    private

    def st_data_validation(st_data)
      st_data.map { |row| row['limpar_id'].present? }.all?
    end

    def prepare_error_message(factoid, e)
      responce = JSON.parse(e.response[:body])['errors']
      errors   = []
      responce.each do |error|
        errors << "#{error['source']['attribute']} => #{error['detail']}"
      end

      "Factoid #{factoid.id} has #{errors.size > 1 ? 'errors' : 'an error'}: #{errors.join('; ')}"
    end
  end
end
