# frozen_string_literal: true

class WorkRequestObjectCreator
  def self.create_from!(account, params)
    new(account, params).send(:create!)
  end

  private

  def initialize(account, params)
    @creator = account
    @prm = params.reject! { |k, v| k.start_with?('tf_') && v.eql?('0') }

    @work_types =
      @prm.select { |k, _v| k.start_with?('tf_work_type') }.keys.map { |k| WorkType.find(k.split('__').last) }
    @clients =
      @prm.select { |k, _v| k.start_with?('tf_client') }.keys.map { |k| Client.find(k.split('__').last) }
    @rev_types =
      @prm.select { |k, _v| k.start_with?('tf_revenue_type') }.keys.map { |k| RevenueType.find(k.split('__').last) }

    @prm.reject! { |k, _v| k.start_with?('tf_') }
  end

  def create!
    request = WorkRequest.create!(
      requester: @creator,
      underwriting_project: UnderwritingProject.find_by(id: @prm['underwriting_project']),
      invoice_type: InvoiceType.find_by(id: @prm['invoice_type']),
      invoice_frequency: InvoiceFrequency.find_by(id: @prm['invoice_frequency']),
      priority: Priority.find_by(id: @prm['priority']),
      sow: @prm['sow'],
      first_invoice: @prm['first_invoice'],
      final_invoice: @prm['final_invoice'],
      goal_deadline: @prm['goal_deadline'],
      final_deadline: @prm['final_deadline'],
      budget_of_project: @prm['budget_of_project']
    )

    request.project_order_name.update(body: @prm['project_order_name'])
    request.project_order_details.update(body: @prm['project_order_details'])
    request.most_worried_details.update(body: @prm['most_worried_details'])
    request.budget_for_project.update(body: @prm['budget_for_project'])

    @work_types.each { |wt| request.work_types << wt }
    @clients.each { |cl| request.clients << cl }
    @rev_types.each { |rt| request.revenue_types << rt }

    request
  end
end
