# frozen_string_literal: true

class WorkRequestAOP
  def self.setup!(work_request, params)
    new(work_request, params).send(:setup)
  end

  private

  def initialize(work_request, params)
    @work_request = work_request
    @a_o_p_ids =
      params.to_h.map { |_uid, row| row }.uniq { |row| [row[:agency_id], row[:opportunity_id]] }
  end

  def setup
    @work_request.opportunities.destroy_all

    @a_o_p_ids.each do |row|
      main_agency = MainAgency.find(row[:agency_id])
      main_opportunity = MainOpportunity.find(row[:opportunity_id])
      percent = row[:percent]

      @work_request.opportunities.create(
        main_agency: main_agency,
        main_opportunity: main_opportunity,
        percent: percent
      )
    end
  end
end
