# frozen_string_literal: true

module ArticleTypes
  class TopicsController < ApplicationController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :render_403, if: :editor?
    before_action :find_topic, only: :change

    def change
      @article_type.update!(topic: @topic, current_account: current_account)
    end

    def get_descriptions
      kind = Kind.sub_kinds.find(params[:kind])
      @topics = kind.parent_kind.topics.actual.order(:description)
    end

    private

    def find_topic
      @topic = Topic.find(params[:id])
    end
  end
end
