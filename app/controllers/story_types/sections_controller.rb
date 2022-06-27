# frozen_string_literal: true

module StoryTypes
  class SectionsController < StoryTypesController
    before_action :find_client_publication_tag
    before_action :find_section_by_name, only: :create
    before_action :find_section_by_id, only: :destroy

    def create
      render_403 && return if @client_publication_tag.sections.exists?(@section.id)

      @client_publication_tag.sections << @section
      render 'story_types/sections/refresh_sections'
    end

    def destroy
      render_403 && return unless @client_publication_tag.sections.exists?(@section.id)

      @client_publication_tag.sections.destroy(@section)
      render 'story_types/sections/refresh_sections'
    end

    private

    def find_client_publication_tag
      @client_publication_tag =
        @story_type.clients_publications_tags.find(params[:client_publication_tag])
    end

    def find_section_by_name
      @section = Section.find_by(name: params[:section])
    end

    def find_section_by_id
      @section = Section.find(params[:id])
    end
  end
end
