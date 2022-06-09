# frozen_string_literal: true

module StoryTypes
  class StoriesController < StoryTypesController # :nodoc:
    skip_before_action :find_parent_article_type
    skip_before_action :set_article_type_iteration

  end
end
