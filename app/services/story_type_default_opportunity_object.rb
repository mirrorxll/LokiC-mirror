# frozen_string_literal: true

class StoryTypeDefaultOpportunityObject
  def self.update(st_def_opportunity, params)
    new(st_def_opportunity, params).send(:upd)
  end

  private

  def initialize(st_def_opportunity, params)
    @st_def_opportunity = st_def_opportunity
    @action = params.delete(:action)
    @params = params
  end

  def upd
    @st_def_opportunity.update!(
      case @action
      when 'opportunity'
        {
          opportunity: Opportunity.find_by(id: @params[:opportunity_id]),
          opportunity_type: nil, content_type: nil
        }
      when 'opportunity type'
        { opportunity_type: OpportunityType.find_by(id: @params[:opportunity_type_id]) }
      when 'content type'
        { content_type: ContentType.find_by(id: @params[:content_type_id]) }
      end
    )

    @st_def_opportunity
  end
end
