# frozen_string_literal: true

module FactoidTypes
  class TopicsController < FactoidTypesController # :nodoc:
    before_action :find_topic, only: :change

    def change
      @factoid_type.update!(topic: @topic, current_account: @current_account)
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
