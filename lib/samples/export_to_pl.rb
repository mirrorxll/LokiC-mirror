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
    end

    def export!(iteration, threads_count)
      samples_to_export = iteration.samples.ready_to_export.limit(10_000).to_a
      main_semaphore = Mutex.new
      exported = 0

      threads = Array.new(threads_count) do

        Thread.new do
          pl_rep_client = PipelineReplica[@environment]

          loop do
            sample = main_semaphore.synchronize { samples_to_export.shift }
            break if sample.nil?

            lead_story_post(sample, pl_rep_client)
            main_semaphore.synchronize { exported += 1 }
          end

        ensure
          pl_rep_client.close
        end

      end

      threads.each(&:join)
      iteration.update(last_export_batch_size: exported)
    end

    def remove!(iteration)
      semaphore = Mutex.new
      samples = iteration.samples.exported.limit(10_000).to_a

      threads = Array.new(5) do
        Thread.new do
          loop do
            sample = semaphore.synchronize { samples.shift }
            break if sample.nil?

            @pl_client.delete_lead_safe(sample[@pl_lead_id_key])
            sample.update(@pl_lead_id_key => nil, @pl_story_id_key => nil)
          end
        end
      end

      threads.each(&:join)
      iteration.update(export: nil)
    end
  end
end
