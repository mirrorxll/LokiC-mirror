# frozen_string_literal: true

module StoryTypes
  class ExportConfigurationsJob < StoryTypesJob
    def perform(story_type_id, account_id, manual = false)
      story_type = StoryType.find(story_type_id)
      account = Account.find(account_id)
      status = true
      message = 'Success. Export configurations created'
      exp_config_counts = {}
      exp_config_counts.default = 0
      iteration = story_type.iteration
      blank_tag = Tag.find_by(name: '_Blank')

      st_cl_pub_tgs = story_type.clients_publications_tags.sort_by { |st_cl_pub_tg| sort_weight(st_cl_pub_tg) }

      story_type.staging_table.publication_ids.each do |pub_id|
        publication = Publication.find_by(pl_identifier: pub_id)
        cl_pub_tg = st_client_publication_tag(st_cl_pub_tgs, publication)
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
        SlackIterationNotificationJob.new.perform(iteration.id, 'export configurations', message)
      end
    end

    private

    def sort_weight(st_cl_pub_tg)
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

    def st_client_publication_tag(clients_publications_tags, publication)
      clients_publications_tags.to_a.find do |client_publication_tag|
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
    end
  end
end
