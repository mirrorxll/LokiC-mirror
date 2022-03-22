# frozen_string_literal: true

module StoryTypes
  class CronTabJob < StoryTypesJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      cron_tab = story_type.cron_tab
      return if cron_tab.freeze_execution || !cron_tab.enabled

      unless story_type.status.name.eql?('on cron')
        story_type.update!(status: Status.find_by(name: 'on cron'), current_account: account)
      end

      story_type.sidekiq_break.update!(cancel: false)

      account = story_type.developer || Account.find_by(email: 'main@lokic.loc')
      cron_tab_iteration = story_type.cron_tab_iteration || story_type.create_cron_tab_iteration!
      publication_ids = cron_tab_iteration.story_type.publication_pl_ids
      staging_table = story_type.staging_table
      blank_tag = Tag.find_by(name: '_Blank')
      state_lvl_clients = ['Metric Media', 'LGIS', 'Metro Business Network']

      # 0 - all
      # 1 - all local
      # 2 - all statewide
      aggr_pubs = ['all publications', 'all local publications', 'all statewide publications']

      exp_config_status = true
      sample_status = true
      creation_status = true
      export_status = true

      # POPULATION
      cron_tab_iteration.update!(population: false, population_args: cron_tab.population_params, current_account: account)

      begin
        staging_table.default_iter_id(cron_tab_iteration.id)

        population_args = cron_tab.population_params.split(' :: ').each_with_object({}) do |option, hash|
          next unless option.match?(/=>/)

          key, value = option.split('=>')
          hash[key] = value
        end

        MiniLokiC::StoryTypeCode[story_type].execute(:population, population_args)
      rescue StandardError => e
        staging_table.purge_current_iteration
        staging_table.default_iter_id(story_type.iteration.id)
        cron_tab_iteration.update!(population: nil, current_account: account)
        SlackNotificationJob.perform_now(cron_tab_iteration, 'crontab', e.message)
        return
      end

      if staging_table.iteration_rows_absent?(cron_tab_iteration)
        staging_table.default_iter_id(story_type.iteration.id)
        cron_tab_iteration.update!(population: nil, current_account: account)
        message = "Population didn't add new rows to staging table. "\
                  "New iteration didn't create. CronTab execution was stopped"
        SlackNotificationJob.perform_now(cron_tab_iteration, 'crontab', message)
        return
      end

      story_type.update!(current_iteration: cron_tab_iteration, current_account: account)
      cron_tab_iteration.update!(cron_tab: false, population: true, name: DateTime.now.strftime('CT%Y%m%d'))

      # EXPORT CONFIGURATION
      story_type.update!(export_configurations_created: false, current_account: account)

      begin
        st_cl_pub_tgs = story_type.clients_publications_tags.sort_by do |st_cl_pub_tg|
          # st_cl_pubs with pub
          if !st_cl_pub_tg.publication.nil? && !st_cl_pub_tg.publication.name.in?(aggr_pubs)
            1
          # st_cl_pubs all local publications and all statewide publications except Metric Media and Metro Business Network
          elsif !st_cl_pub_tg.client.name.in?(state_lvl_clients) &&
                !st_cl_pub_tg.publication.nil? && st_cl_pub_tg.publication.name.in?(aggr_pubs[1..2])
            2
          # all st_cl_pubs all publications except Metric Media and Metro Business Network
          elsif !st_cl_pub_tg.client.name.in?(state_lvl_clients) &&
                (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name.eql?(aggr_pubs[0]))
            3
          # st_cl_pubs all local publications and all statewide publications Metric Media and Metro Business Network
          elsif st_cl_pub_tg.client.name.in?(state_lvl_clients) &&
                st_cl_pub_tg.publication && st_cl_pub_tg.publication.name.in?(aggr_pubs[1..2])
            4
          # all st_cl_pubs all publications Metric Media and Metro Business Network
          elsif st_cl_pub_tg.client.name.in?(state_lvl_clients) &&
                (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name.eql?(aggr_pubs[0]))
            5
          end
        end

        story_type.staging_table.publication_ids.each do |pub_id|
          publication = Publication.find_by!(pl_identifier: pub_id)

          cl_pub_tg = st_cl_pub_tgs.to_a.find do |client_publication_tag|
            client = client_publication_tag.client
            publications =
              if client_publication_tag.publication.nil?
                client.publications
              elsif client_publication_tag.publication.name.eql?(aggr_pubs[2])
                client.statewide_publications
              elsif client_publication_tag.publication.name.eql?(aggr_pubs[1])
                client.local_publications
              else
                client.publications
              end

            if client_publication_tag.publication.nil? || client_publication_tag.publication.name.in?(state_lvl_clients)
              publications.exists?(publication.id)
            else
              client_publication_tag.publication.eql?(publication)
            end
          end

          next if publication.nil? || cl_pub_tg.nil?

          ExportConfiguration.find_or_initialize_by(
            story_type: story_type,
            publication: publication
          ).update(
            photo_bucket: story_type.photo_bucket,
            tag: (cl_pub_tg.tag && publication.tag?(cl_pub_tg.tag) ? cl_pub_tg.tag : blank_tag)
          )
        end
      rescue StandardError
        exp_config_status = nil
        SlackNotificationJob.perform_now(cron_tab_iteration, 'crontab', "[ ExportConfigurationsError ] -> #{e.message}")
      end

      story_type.update!(export_configurations_created: exp_config_status, current_account: account)
      return unless exp_config_status

      # SAMPLES
      cron_tab_iteration.update!(samples: false, sample_args: {}, current_account: account)

      sample_ids = Table.select_edge_ids(staging_table.name, [:id], *publication_ids).join(',')
      sample_options = {
        cron: true,
        sampled: true,
        iteration: cron_tab_iteration,
        publication_ids: publication_ids,
        ids: sample_ids,
        type: 'story'
      }

      begin
        MiniLokiC::StoryTypeCode[cron_tab_iteration.story_type].execute(:creation, sample_options)
        Samples.auto_feedback(cron_tab_iteration, true)
      rescue StandardError => e
        raise = true
        sample_status = nil
      end

      cron_tab_iteration.update!(samples: sample_status, current_account: account)
      return if raise || cron_tab_iteration.story_type.sidekiq_break.reload.cancel

      cron_tab_iteration.stories.where(staging_row_id: sample_ids).update_all(sampled: true)

      # CREATION
      cron_tab_iteration.update!(creation: false, current_account: account)

      creation_options = {
        iteration: cron_tab_iteration,
        publication_ids: publication_ids,
        type: 'story'
      }

      begin
        loop do
          break if story_type.sidekiq_break.reload.cancel ||
                   Table.all_stories_created_by_iteration?(staging_table, publication_ids)

          MiniLokiC::StoryTypeCode[cron_tab_iteration.story_type].execute(:creation, creation_options)
        end

        counts = Hash.new(0)
        counts[:total] = cron_tab_iteration.stories.count

        unless counts[:total].zero?
          cron_tab_iteration.story_type.clients_publications_tags.each_with_object(counts) do |row, obj|
            client = row.client
            pubs = client.publications
            counts = pubs.joins(:stories).where(stories: { iteration: cron_tab_iteration })
                         .group(:publication_id).order('count(publication_id) desc')
                         .count(:publication_id)
            next if counts.empty?

            obj[client.name.to_sym] = counts.first[1]
          end
        end

        cron_tab_iteration.update!(schedule_counts: schedule_counts(cron_tab_iteration), current_account: account)
      rescue StandardError
        raise = true
        creation_status = nil
      end

      cron_tab_iteration.update!(creation: creation_status, current_account: account)
      return if raise || cron_tab_iteration.story_type.sidekiq_break.reload.cancel

      if cron_tab_iteration.stories.where(published_at: nil).limit(1).present?
        message = "Scheduling didn't complete. Please check passed params to it"
        SlackNotificationJob.perform_now(cron_tab_iteration, 'crontab', message)
        return
      end

      # EXPORT
      cron_tab_iteration.update!(export: false, last_export_batch_size: nil, current_account: account)

      threads_count = (cron_tab_iteration.stories.count / 75_000.0).ceil + 1
      threads_count = threads_count > 20 ? 20 : threads_count

      begin
        loop do
          Samples[PL_TARGET].export!(cron_tab_iteration, threads_count)

          break if cron_tab_iteration.reload.last_export_batch_size.zero?
        end

        exp_st = ExportedStoryType.find_or_initialize_by(iteration: cron_tab_iteration)

        if exp_st.new_record?
          story_type.update!(last_export: DateTime.now, current_account: account)

          exp_st.week = Week.where(begin: Date.today - (Date.today.wday - 1)).first
          exp_st.date_export = Date.today
          exp_st.story_type = story_type
          exp_st.first_export = cron_tab_iteration.name.eql?('Initial')
        end

        exp_st.developer = account
        exp_st.count_samples = cron_tab_iteration.stories.count
        exp_st.save!

        note = MiniLokiC::Formatize::Numbers.to_text(exp_st.count_samples).capitalize
        record_to_change_history(story_type, 'exported to pipeline', note, account)
      rescue StandardError
        raise = true
        export_status = nil
      end

      return if raise || cron_tab_iteration.story_type.sidekiq_break.reload.cancel

      cron_tab_iteration.reload.update!(export: export_status)
      story_type.sidekiq_break.update!(cancel: false)
    rescue StandardError, ScriptError => e
      raise CronTabExecutionError,
            "[ CronTabExecutionError ] -> #{e.message}#{" at #{e.backtrace.first}"}".gsub('`', "'")
    end
  end
end
