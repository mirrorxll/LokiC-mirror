# frozen_string_literal: true

module FactoidTypes
  class SamplesJob < FactoidTypesJob
    def perform(iteration_id, account_id, options = {})
      options.deep_symbolize_keys!

      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)
      options[:iteration] = iteration
      options[:sampled] = true

      status = true
      staging_table = iteration.factoid_type.staging_table
      sampled_before = iteration.factoids.where(sampled: true).count
      column_names = staging_table.columns.ids_to_names(options[:columns])
      sample_args = { columns: column_names, ids: options[:row_ids] }
      edge_ids = Table.select_edge_ids(staging_table.name, column_names)
      row_ids = options[:row_ids].delete(' ').split(',')
      ids = edge_ids + row_ids
      iteration_rows_count = Table.rows_by_iter(staging_table.name, iteration_id)

      options = options.merge({ ids: ids.join(','), type: 'article' })
      iteration.update!(sample_args: sample_args, current_account: account)

      MiniLokiC::ArticleTypeCode[iteration.factoid_type].execute(:creation, options)

      iteration.factoids.where(staging_row_id: ids).update_all(sampled: true)

      sampled_after = iteration.factoids.where(sampled: true).count
      message =
        if sampled_before.eql?(sampled_after)
          "New samples haven't been created by passed params. Check it!"
        else
          'Success. Samples have been created'
        end

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      fields = { samples: status, current_account: account }
      fields.merge!(creation: true) if iteration.factoids.count.eql?(iteration_rows_count) && status
      iteration.update!(fields)
      send_to_action_cable(iteration.factoid_type, :samples, message)
      SlackIterationNotificationJob.perform_async(iteration.id, 'samples', message)
    end
  end
end
