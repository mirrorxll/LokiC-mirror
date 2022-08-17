# frozen_string_literal: true

module FactoidTypes
  module Iterations
    class PurgeFactoidsTask < FactoidTypesTask
      def perform(iteration_id, account_id, factoid_ids)
        iteration          = FactoidTypeIteration.find(iteration_id)
        account            = Account.find(account_id)
        array_of_dis       = factoid_ids.split(',')
        message            = 'Success'
        factoid_type       = iteration.factoid_type
        factoids           = iteration.factoids.where(limpar_factoid_id: array_of_dis)
        staging_table_name = factoid_type.staging_table.name
        st_table_rows      = factoids.pluck(:staging_row_id)

        Table.delete_rows_from_st_table(staging_table_name, st_table_rows)
        Factoids::ExportToLp.new.unpublish!(iteration, array_of_dis)

        note = MiniLokiC::Formatize::Numbers.to_text(iteration.factoids.published.count)
        record_to_change_history(factoid_type, 'removed factoids from everywhere', note, account)

      rescue StandardError, ScriptError => e
        message = e.message
      ensure
        if iteration.factoids.count.zero?
          %w[population population_args purge_population samples sample_args purge_samples creation
             purge_creation export purge_export last_export_batch_size].each do |prop|
            iteration.update!(prop.to_sym => nil)
          end
          send_to_action_cable(iteration.factoid_type, :staging_table, message)
        else
          iteration.update!(purge_export: false)
          send_to_action_cable(iteration.factoid_type, :export, message)
        end
        SlackIterationNotificationTask.new.perform(iteration.id, 'remove from everywhere', message)
      end
    end
  end
end
