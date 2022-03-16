# frozen_string_literal: true

module StoryTypes
  class CronTabJob < StoryTypesJob
    def perform(story_type_id)
      story_type = StoryType.find(story_type_id)
      cron_tab = story_type.cron_tab
      return if cron_tab.freeze_execution || !cron_tab.enabled

      story_type.sidekiq_break.update!(cancel: false)

      account = story_type.developer || Account.find_by(email: 'main@lokic.loc')
      iteration = story_type.cron_tab_iteration || story_type.create_cron_tab_iteration!
      staging_table = story_type.staging_table

      staging_table.default_iter_id(iteration.id)
      iteration.update!(population: false, population_args: cron_tab.population_params, current_account: account)

      population_args = cron_tab.population_params.split(' :: ').each_with_object({}) do |option, hash|
        next unless option.match?(/=>/)

        key, value = option.split('=>')
        hash[key] = value
      end

      MiniLokiC::StoryTypeCode[story_type].execute(:population, population_args)

      unless story_type.status.name.in?(['in progress', 'on cron'])
        story_type.update!(status: Status.find_by(name: 'in progress'), current_account: account)
      end

      exp_config_status = true
      exp_config_message = 'Success. Export configurations created'
      iteration = story_type.iteration
      blank_tag = Tag.find_by(name: '_Blank')

      st_cl_pub_tgs = story_type.clients_publications_tags.sort_by do |st_cl_pub_tg|
        # st_cl_pubs with pub
        return 1 if !st_cl_pub_tg.publication.nil? &&
          !st_cl_pub_tg.publication.name.in?(['all local publications', 'all statewide publications', 'all publications'])

        # st_cl_pubs all local publications and all statewide publications except Metric Media and Metro Business Network
        return 2 if !st_cl_pub_tg.client.name.in?(['Metric Media', 'Metro Business Network']) &&
          !st_cl_pub_tg.publication.nil? &&
          st_cl_pub_tg.publication.name.in?(['all local publications', 'all statewide publications'])

        # all st_cl_pubs all publications except Metric Media and Metro Business Network
        return 3 if !st_cl_pub_tg.client.name.in?(['Metric Media', 'Metro Business Network']) &&
          (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name == 'all publications')

        # st_cl_pubs all local publications and all statewide publications Metric Media and Metro Business Network
        return 4 if st_cl_pub_tg.client.name.in?(['Metric Media', 'Metro Business Network']) && st_cl_pub_tg.publication &&
          st_cl_pub_tg.publication.name.in?(['all local publications', 'all statewide publications'])

        # all st_cl_pubs all publications Metric Media and Metro Business Network
        5 if st_cl_pub_tg.client.name.in?(['Metric Media', 'Metro Business Network']) &&
          (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name == 'all publications')
      end

      story_type.staging_table.publication_ids.each do |pub_id|
        publication = Publication.find_by(pl_identifier: pub_id)
        cl_pub_tg = st_cl_pub_tgs.to_a.find do |client_publication_tag|
          client = client_publication_tag.client
          publications = if client_publication_tag.publication.nil?
                           client.publications
                         elsif client_publication_tag.publication.name == 'all statewide publications'
                           client.statewide_publications
                         elsif client_publication_tag.publication.name == 'all local publications'
                           client.local_publications
                         else
                           client.publications
                         end

            client_publication_tag.publication.nil? || client_publication_tag.publication.name.in?(['all local publications', 'all statewide publications', 'all publications']) ? publications.exists?(publication.id) : client_publication_tag.publication == publication
          end

          next if publication.nil? || cl_pub_tg.nil?

          exp_c = ExportConfiguration.find_or_initialize_by(
            story_type: story_type,
            publication: publication
          )

          exp_c.photo_bucket = story_type.photo_bucket
          exp_c.tag = (cl_pub_tg.tag && publication.tag?(cl_pub_tg.tag) ? cl_pub_tg.tag : blank_tag)
          exp_c.save!
        end
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
      ensure
        story_type.update!(export_configurations_created: status, current_account: account)

        if manual
          send_to_action_cable(story_type, :properties, message)
          StoryTypes::SlackNotificationJob.perform_now(iteration, 'export configurations', message)
        end







      if story_type.sidekiq_break.reload.cancel
        status = nil
        message = 'Canceled'
      end

        if exception.present?
          klass, message = JSON.parse(exception).to_a.first
          raise Object.const_get(klass), message
        end

        false
      rescue StandardError, ScriptError => e
        status = nil
        message = e.message
        true
      ensure
        iteration.update!(population: status, current_account: account)
        story_type.sidekiq_break.update!(cancel: false)
        send_to_action_cable(story_type, :staging_table, message)
        StoryTypes::SlackNotificationJob.perform_now(iteration, 'population', message)
      end


      if population_raise
        Table.purge_last_iteration(staging_table.name)
        staging_table.default_iter_id(story_type.iteration.id)
        return
      end

      if Table.rows_absent?(staging_table.name, iteration.id)
        staging_table.default_iter_id(story_type.iteration.id)
        message = "Population didn't add new rows to staging table. "\
                  "New iteration didn't create. CronTab execution was stopped"
        SlackNotificationJob.perform_now(iteration, 'crontab', message)
        return
      else
        story_type.update!(current_iteration: iteration, current_account: account)
        iteration.update!(cron_tab: false)
        iteration.update!(name: DateTime.now.strftime('CT%Y%m%d')) if iteration.name.blank?
      end

      iteration.update!(samples: false, current_account: account)
      creation_raise = SamplesAndAutoFeedbackJob.perform_now(iteration, account, cron: true)

      return if creation_raise || iteration.story_type.sidekiq_break.reload.cancel

      iteration.update!(creation: false, current_account: account)
      creation_raise = CreationJob.perform_now(iteration, account)

      return if creation_raise || iteration.story_type.sidekiq_break.reload.cancel

      not_scheduled = iteration.stories.where(published_at: nil).limit(1).present?

      if not_scheduled
        message = "Scheduling didn't complete. Please check passed params to it"
        SlackNotificationJob.perform_now(iteration, 'crontab', message)
        return
      end

      iteration.update!(export: false, current_account: account)
      ExportJob.perform_later(iteration, account)
    end
  end
end
