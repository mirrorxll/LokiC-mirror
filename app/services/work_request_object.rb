# frozen_string_literal: true

class WorkRequestObject
  def self.create_from!(params)
    new(params: params).send(:update!)
  end

  def self.update_from!(work_request, params)
    new(work_request: work_request, params: params).send(:update!)
  end

  private

  def initialize(work_request: nil, params:)
    @request = work_request || WorkRequest.create!
    @prm = params.reject! { |k, v| k.start_with?('tf_') && v.eql?('0') }

    @work_types =
      @prm.select { |k, _v| k.start_with?('tf_work_type') }.keys.map { |k| WorkType.find(k.split('__').last) }
    @clients =
      @prm.select { |k, _v| k.start_with?('tf_client') }.keys.map { |k| Client.find(k.split('__').last) }
    @rev_types =
      @prm.select { |k, _v| k.start_with?('tf_revenue_type') }.keys.map { |k| RevenueType.find(k.split('__').last) }

    @prm.reject! { |k, _v| k.start_with?('tf_') }
  end

  def update!
    params = {
      requester: @request&.requester || @prm['account'],
      underwriting_project: UnderwritingProject.find_by(id: @prm['underwriting_project']),
      invoice_type: InvoiceType.find_by(id: @prm['invoice_type']),
      invoice_frequency: InvoiceFrequency.find_by(id: @prm['invoice_frequency']),
      priority: Priority.find_by(id: @prm['priority']),
      sow: @prm['sow'],
      eta: @prm['eta'],
      first_invoice: @prm['first_invoice'],
      final_invoice: @prm['final_invoice'],
      goal_deadline: @prm['goal_deadline'],
      final_deadline: @prm['final_deadline'],
      budget_of_project: @prm['budget_of_project']
    }

    @request.update!(params)
    @request.project_order_name.update(body: @prm['project_order_name'])
    @request.project_order_details.update(body: @prm['project_order_details'])
    @request.most_worried_details.update(body: @prm['most_worried_details'])
    @request.budget_for_project.update(body: @prm['budget_for_project'])

    @work_types.each { |wt| @request.work_types << wt unless @request.work_types.exists?(wt.id) }
    @clients.each { |cl| @request.clients << cl unless @request.clients.exists?(cl.id) }
    @rev_types.each { |rt| @request.revenue_types << rt unless @request.revenue_types.exists?(rt.id) }

    @request
  end
end
