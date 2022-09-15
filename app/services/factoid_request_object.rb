# frozen_string_literal: true

class FactoidRequestObject
  def self.create_from!(params)
    new(params: params).send(:update!)
  end

  def self.update_from!(factoid_request, params)
    new(factoid_request: factoid_request, params: params).send(:update!)
  end

  private

  def initialize(factoid_request: nil, params:)
    @request = factoid_request || FactoidRequest.new
    @prm = params.reject { |k, v| k.start_with?('tf_') && v.eql?('0') }

    @data_sets =
      @prm.select { |k, _v| k.start_with?('tf_data_set') }.keys.map { |k| DataSet.find(k.split('__').last) }

    @prm.reject! { |k, _v| k.start_with?('tf_') }
  end

  def update!
    params = {
      requester: @request&.requester || @prm[:account],
      name: @prm[:name].strip,
      agency: Agency.find_by(id: @prm[:agency_id]),
      opportunity: Opportunity.find_by(id: @prm[:opportunity_id]),
      frequency: Frequency.find_by(id: @prm[:frequency_id]),
      google_doc_sheet_link: @prm[:google_doc_sheet_link],
      priority: Priority.find_by(id: @prm[:priority_id])
    }

    @request.update!(params)

    @request.description.update!(body: @prm[:description])
    @request.purpose.update!(body: @prm[:purpose])

    @data_sets.each { |ds| @request.data_sets << ds unless @request.data_sets.exists?(ds.id) }

    (1..5).each do |n|
      @request.public_send("template_#{n}_body").update!(body: @prm[:"template_#{n}_body"])
      @request.public_send("template_#{n}_assoc").update!(body: @prm[:"template_#{n}_assoc"])
    end

    @request
  end
end
