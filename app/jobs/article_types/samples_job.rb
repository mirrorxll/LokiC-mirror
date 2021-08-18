# frozen_string_literal: true

module ArticleTypes
  class SamplesJob < ArticleTypeJob
    def perform(iteration, account, options = {})
      options[:iteration] = iteration
      options[:sampled] = true

      status = true
      staging_table = iteration.article_type.staging_table
      sampled_before = iteration.articles.where(sampled: true).count
      column_names = staging_table.columns.ids_to_names(options[:columns])
      sample_args = { columns: column_names, ids: options[:row_ids] }
      edge_ids = Table.select_edge_ids(staging_table.name, column_names)
      row_ids = options[:row_ids].delete(' ').split(',')
      ids = edge_ids + row_ids

      options = options.merge({ ids: ids.join(','), type: 'article' })
      iteration.update!(sample_args: sample_args, current_account: account)

      rd, wr = IO.pipe

      Process.wait(
        fork do
          rd.close

          MiniLokiC::ArticleTypeCode[iteration.article_type].execute(:creation, options)
        rescue StandardError, ScriptError => e
          wr.write({ e.class.to_s => e.message }.to_json)
        ensure
          wr.close
        end
      )

      wr.close
      exception = rd.read
      rd.close

      if exception.present?
        klass, message = JSON.parse(exception).to_a.first
        raise Object.const_get(klass), message
      end

      iteration.articles.where(staging_row_id: ids).update_all(sampled: true)

      sampled_after = iteration.articles.where(sampled: true).count
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
      iteration.update!(samples: status, current_account: account)
      send_to_action_cable(iteration.article_type, :samples, message)
    end
  end
end
