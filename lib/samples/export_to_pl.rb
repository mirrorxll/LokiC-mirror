# frozen_string_literal: true

module Samples
  class ExportToPl
    include Export::LeadStoryPost

    def initialize(environment)
      @environment = environment
      @pl_client = Pipeline[environment]
      @pl_lead_id_key = "pl_#{environment}_lead_id".to_sym
      @pl_story_id_key = "pl_#{environment}_story_id".to_sym
      @pub_aggregate_names = ['all local publications', 'all statewide publications', 'all publications']
    end

    def export!(iteration, options = {})
      clients_publications_tags = iteration.story_type.clients_publications_tags.to_a
      story_type = iteration.story_type
      st_opportunities = story_type.opportunities
      main_semaphore = Mutex.new
      exported = 0
      forbidden_mb_pubs = [1635, 1149, 1148, 1656, 1659, 1669, 1670]

      stories_to_export =
        if options[:backdated]
          iteration.stories.backdated_to_export.limit(10_000).to_a
        else
          iteration.stories.ready_to_export.limit(10_000).to_a
        end

      @staging_table_name = story_type.staging_table.name

      threads = Array.new(options[:threads_count]) do
        Thread.new do
          loop do
            sample = main_semaphore.synchronize { stories_to_export.shift }
            break if sample.nil? || story_type.sidekiq_break.reload.cancel
            break if options[:backdated] && Time.now >= options[:backdated][:stop_at]

            sample.destroy and next if sample.publication.pl_identifier.in?(forbidden_mb_pubs)

            lead_story_post(
              sample,
              clients_publications_tags,
              st_opportunities
            )
            main_semaphore.synchronize { exported += 1 }
          end
        end
      end
      threads.each(&:join)

      iteration.update!(last_export_batch_size: exported) unless options[:backdated]
    end

    def remove!(iteration)
      semaphore = Mutex.new
      stories = iteration.stories.exported.limit(10_000).to_a
      story_type = iteration.story_type

      threads = Array.new(5) do
        Thread.new do
          loop do
            sample = semaphore.synchronize { stories.shift }
            break if sample.nil?

            begin
              @pl_client.delete_lead(sample[@pl_lead_id_key])
            rescue Faraday::ResourceNotFound
              true
            end

            sample.update!(@pl_lead_id_key => nil, @pl_story_id_key => nil, exported_at: nil)
            break if story_type.reload.sidekiq_break.cancel
          end
        end
      end

      threads.each(&:join)
    end
  end
end
