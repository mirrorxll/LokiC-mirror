module StoryTypes
  class SectionsController < ApplicationController
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :developer?
    before_action :find_client_publication_tag
    before_action :find_section_by_name, only: :create
    before_action :find_section_by_id, only: :destroy

    def include
      render_403 && return if @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: @tag)
    end

    def exclude
      render_403 && return unless @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: nil)
    end

    def create
      render_403 && return if @client_publication_tag.sections.exists?(@section.id)

      @client_publication_tag.sections << @section
    end

    def destroy
      render_403 && return unless @client_publication_tag.sections.exists?(@section.id)

      @client_publication_tag.sections.destroy(@section)
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
