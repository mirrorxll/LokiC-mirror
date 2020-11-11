# frozen_string_literal: true

require_relative 'export/lead_story_post.rb'

module Samples
  class ExportToPl
    include Export::LeadStoryPost

    def initialize(environment)
      @environment = environment
      @pl_client = Pipeline[environment]
      @pl_lead_id_key = "pl_#{environment}_lead_id".to_sym
      @pl_story_id_key = "pl_#{environment}_story_id".to_sym
      @story_type = nil
    end

    def export!(story_type)
      @story_type = story_type
      iteration_samples = samples(story_type)
      threads = (iteration_samples.count / 75_000.0).ceil + 1
      raw_report = { skipped: 0 }

      iteration_samples.find_in_batches(batch_size: 10_000) do |samples|
        main_semaphore = Mutex.new
        samples_to_export = samples.to_a

        threads = Array.new(threads) do
          Thread.new do
            pl_rep_client = PipelineReplica[@environment]

            loop do
              sample = main_semaphore.synchronize { samples_to_export.shift }
              break if sample.nil?

              lead_story_post(sample, pl_rep_client)
            rescue Samples::Error
              raw_report[:skipped] += 1
            end
          ensure
            pl_rep_client.close
          end
        end

        threads.each(&:join)
      end

      generate_report(raw_report)
    end

    private

    def samples(story_type)
      story_type.iteration.samples.where(@pl_story_id_key => nil)
                .joins(:export_configuration, :publication, :output)
                .order(:published_at).where(backdated: false)
                .where.not(export_configurations: { tag: nil })
    end

    def generate_report(raw_report)
      status =
        if raw_report[:skipped].positive?
          'not ended, please press the extra-export button.'
        else
          'success.'
        end

      "*skipped:* #{raw_report[:skipped]}\nstatus: #{status}"
    end
  end
end
