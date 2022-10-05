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
    @request = work_request || WorkRequest.new
    @prm = params.reject { |k, v| k.start_with?('tf_') && v.eql?('0') }

    @work_types =
      @prm.select { |k, _v| k.start_with?('tf_work_type') }.keys.map { |k| WorkType.find(k.split('__').last) }
    # @clients =
    #   @prm.select { |k, _v| k.start_with?('tf_client') }.keys.map { |k| Client.find(k.split('__').last) }
    @rev_types =
      @prm.select { |k, _v| k.start_with?('tf_revenue_type') }.keys.map { |k| RevenueType.find(k.split('__').last) }

    @prm.reject! { |k, _v| k.start_with?('tf_') }
  end

  def update!
    params = {
      requester: @request&.requester || @prm['account'],
      priority: Priority.find_by(id: @prm['priority']),
      eta: @prm['eta'],
      goal_deadline: @prm['goal_deadline'],
      final_deadline: @prm['final_deadline'],
      last_invoice: @prm['last_invoice']
    }
    params.merge!(default_sow: true) if @request.new_record?

    @request.update!(params)
    @request.project_order_name.update!(body: @prm['project_order_name'].strip)
    @request.project_order_details.update!(body: @prm['project_order_details'])
    @request.most_worried_details.update!(body: @prm['most_worried_details'])

    # @clients.each { |cl| @request.clients << cl unless @request.clients.exists?(cl.id) }

    WorkRequestAOP.setup!(@request, @prm[:a_op_p])

    @request
  end
end
