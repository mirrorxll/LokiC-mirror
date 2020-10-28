# frozen_string_literal: true

require_relative 'export/lead_story_post.rb'
require_relative 'export/story_update.rb'

module Samples
  class ExportToPl
    include Export::LeadStoryPost
    include Export::StoryUpdate

    def initialize(environment)
      @environment = environment
      @pl_client = Pipeline[environment]
      @pl_lead_id_key = "pl_#{environment}_lead_id".to_sym
      @pl_story_id_key = "pl_#{environment}_story_id".to_sym
      @report = { exported: 0, skipped: 0, errors: { leads: [], stories: [] } }
      @main_semaphore = Mutex.new
      @report_semaphore = Mutex.new
      @story_type = nil
    end

    def export!(story_type)
      @story_type = story_type
      iteration_samples = samples(story_type)
      threads = (iteration_samples.count / 75_000.0).ceil + 1

      iteration_samples.find_in_batches(batch_size: 10_000) do |samples|
        samples_to_export = samples.to_a

        threads = Array.new(threads) do
          Thread.new do
            pl_rep_client = PipelineReplica[@environment]

            loop do
              sample = @main_semaphore.synchronize { samples_to_export.shift }
              break if sample.nil?

              lead_story_post(sample, pl_rep_client)

              @report_semaphore.synchronize do
                @report[:exported] += 1
                @report[:errors].each { |_k, v| v.uniq! }
              end
            rescue Samples::Error => e
              @report_semaphore.synchronize do
                response = JSON.parse(e.message)

                @report[:skipped] += 1
                @report[:errors][:leads] << response if e.class.eql?(Samples::LeadPostError)
                @report[:errors][:stories] << response if e.class.eql?(Samples::StoryPostError)
                @report[:errors].each { |_k, v| v.uniq! }
              end
            end
          ensure
            pl_rep_client.close
          end
        end

        threads.each(&:join)
      end

      generate_report
    end

    private

    def samples(story_type)
      story_type.iteration.samples.where(@pl_story_id_key => nil)
                .joins(:export_configuration, :publication, :output)
                .order(:published_at).where(backdated: false)
                .where.not(export_configurations: { tag: nil })
    end

    def generate_report
      samples = @story_type.iteration.samples
      total_exported = samples.where.not(pl_staging_story_id: nil, backdated: 1).count
      not_exported = samples.where(pl_staging_story_id: nil, backdated: 0).count
      backdated = samples.where(backdated: 1).count

      message = "*exported by iteration:* #{total_exported}\n"\
                "*exported by execution:* #{@report[:exported]}\n"\
                "*not exported yet:* #{not_exported}\n"\
                "*backdated:* #{backdated}\n"

      if @report[:skipped].positive?
        message += "*errors:*\n"

        @report[:errors].each do |stage, e|
          next if e.empty?

          message += "  *#{stage}:*\n"
          e.each { |k, _v| message += "    #{k}\n" }
        end
      end

      message
    end
  end
end
