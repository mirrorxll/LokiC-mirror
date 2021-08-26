# frozen_string_literal: true

module StoryTypes
  class TagsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

    before_action :render_403, if: :developer?
    before_action :find_client_publication_tag
    before_action :find_tag, only: :include

    def include
      render_403 && return if @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: @tag)
    end

    def exclude
      render_403 && return unless @client_publication_tag.tag.present?

      @client_publication_tag.update!(tag: nil)
    end

    private

    def find_client_publication_tag
      @client_publication_tag =
        @story_type.clients_publications_tags.find(params[:client_publication_tag])
    end

    def find_tag
      @tag = Tag.find(params[:id])
    end
  end
end
