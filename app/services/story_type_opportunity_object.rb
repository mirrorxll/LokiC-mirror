# frozen_string_literal: true

class StoryTypeOpportunityObject
  def self.update(st_opportunity, params)
    new(st_opportunity, params).send(:upd)
  end

  private

  def initialize(st_opportunity, params)
    @st_opportunity = st_opportunity
    @action = params.delete(:action)
    @params = params
  end

  def upd
    puts @action
    @st_opportunity.update!(
      case @action
      when 'add opportunity'
        {
          opportunity: Opportunity.find(@params[:opportunity_id]),
          opportunity_type: nil, content_type: nil
        }
      when 'remove opportunity'
        { opportunity: nil, opportunity_type: nil, content_type: nil }
      when 'add opportunity type'
        { opportunity_type: OpportunityType.find(@params[:opportunity_type_id]) }
      when 'remove opportunity type'
        { opportunity_type: nil }
      when 'add content type'
        { content_type: ContentType.find(@params[:content_type_id]) }
      when 'remove content type'
        { content_type: nil }
      end
    )

    @st_opportunity
  end
end
