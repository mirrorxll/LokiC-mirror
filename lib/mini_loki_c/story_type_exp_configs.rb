# frozen_string_literal: true

module MiniLokiC
  # Execute uploaded stage population/story creation code
  class StoryTypeExpConfigs
    def self.[](story_type)
      new(story_type)
    end

    def create_or_update!
      st_cl_pub_tgs = @story_type.clients_publications_tags.sort_by do |st_cl_pub_tg|
        # st_cl_pubs with pub
        if !st_cl_pub_tg.publication.nil? && !st_cl_pub_tg.publication.name.in?(@aggregate_pubs)
          1
          # st_cl_pubs all local publications and all statewide publications except Metric Media and Metro Business Network
        elsif !st_cl_pub_tg.client.name.in?(@state_lvl_clients) &&
              !st_cl_pub_tg.publication.nil? && st_cl_pub_tg.publication.name.in?(@aggregate_pubs[1..2])
          2
          # all st_cl_pubs all publications except Metric Media and Metro Business Network
        elsif !st_cl_pub_tg.client.name.in?(@state_lvl_clients) &&
              (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name.eql?(@aggregate_pubs[0]))
          3
          # st_cl_pubs all local publications and all statewide publications Metric Media and Metro Business Network
        elsif st_cl_pub_tg.client.name.in?(@state_lvl_clients) &&
              st_cl_pub_tg.publication && st_cl_pub_tg.publication.name.in?(@aggregate_pubs[1..2])
          4
          # all st_cl_pubs all publications Metric Media and Metro Business Network
        elsif st_cl_pub_tg.client.name.in?(@state_lvl_clients) &&
              (st_cl_pub_tg.publication.nil? || st_cl_pub_tg.publication.name.eql?(@aggregate_pubs[0]))
          5
        end
      end.to_a

      blank_tag = Tag.find_by(name: '_Blank')

      @story_type.staging_table.publication_ids.each do |pub_id|
        publication = Publication.find_by!(pl_identifier: pub_id)

        cl_pub_tg = st_cl_pub_tgs.find do |client_publication_tag|
          client = client_publication_tag.client

          publications =
            if client_publication_tag.publication.nil?
              client.publications
            elsif client_publication_tag.publication.name.eql?(@aggregate_pubs[2])
              client.statewide_publications
            elsif client_publication_tag.publication.name.eql?(@aggregate_pubs[1])
              client.local_publications
            else
              client.publications
            end

          if client_publication_tag.publication.nil? || client_publication_tag.publication.name.in?(@state_lvl_clients)
            publications.exists?(publication.id)
          else
            client_publication_tag.publication.eql?(publication)
          end
        end

        next if publication.nil? || cl_pub_tg.nil?

        ExportConfiguration.find_or_initialize_by(
          story_type: @story_type,
          publication: publication
        ).update(
          photo_bucket: @story_type.photo_bucket,
          tag: (cl_pub_tg.tag && publication.tag?(cl_pub_tg.tag) ? cl_pub_tg.tag : blank_tag)
        )
      end
    rescue StandardError, ScriptError => e
      raise ExportConfigurationExecutionError,
            "[ ExportConfigurationsExecutionError ] -> #{e.message} at #{e.backtrace.first}".gsub('`', "'")
    end

    private

    def initialize(story_type)
      @story_type = story_type
      @state_lvl_clients = ['Metric Media', 'LGIS', 'Metro Business Network']

      # 0 - all
      # 1 - all local
      # 2 - all statewide
      @aggregate_pubs = ['all publications', 'all local publications', 'all statewide publications']
    end
  end
end
