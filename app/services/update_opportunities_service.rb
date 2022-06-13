# frozen_string_literal: true

class UpdateOpportunitiesService < StoryTypesTask
  def self.perform(params = {}, &block)
    new(params).send(:call, &block)
  end

  private

  def initialize(params = {})
    @params = params
  end

  def call
    story_type.default_opportunities.each do |oppo|
      oppo.opportunity      = oppo.client.opportunities.include?(opportunity) ? opportunity : nil
      oppo.opportunity_type = oppo.opportunity&.opportunity_types.try(:include?, opportunity_type) ? opportunity_type : nil
      oppo.content_type     = oppo.opportunity&.content_types.try(:include?, content_type) ? content_type : nil

      oppo.save!
    end

    StoryTypeOpportunitiesChannel.broadcast_to(story_type, true)
  end

  def story_type
    StoryType.find(params[:story_type_id])
  end

  def opportunity
    Opportunity.find(params[:opportunity_id])
  end

  def opportunity_type
    OpportunityType.find(params[:opportunity_type_id])
  end

  def content_type
    ContentType.find(params[:content_type_id])
  end

  attr_reader :params
end
