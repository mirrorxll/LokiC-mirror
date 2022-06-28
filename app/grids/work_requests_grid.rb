# frozen_string_literal: true

class WorkRequestsGrid
  include Datagrid

  # Scope
  scope { WorkRequest.order(id: :desc) }

  # Filter
  filter(:requester_id)
  filter(:status)

  # Columns
  column(:id, header: 'id')

  priorities = Priority.all.each_with_object({}) do |p, hash|
    hash[p.name] = p.name.split(' - ').first
  end
  column(:priority, header: 'priority') do |req|
    priorities[req.priority.name]
  end

  column(:status, header: 'status', html: true) do |req|
    attributes =
      if req.status.name.in?(%w[blocked canceled])
        {
          'class' => "mouse-hover bg-#{status_color(req.status.name)}",
          'data-toggle' => 'tooltip',
          'data-placement' => 'right',
          'title' => truncate(req.status_comment&.body, length: 150)
        }
      else
        { 'class' => "bg-#{status_color(req.status.name)}" }
      end

    content_tag(:div, attributes) do
      name =
        if req.status.name.in?(%w[blocked canceled])
          "<u>#{req.status.name}&nbsp"\
          "#{icon('fa', 'commenting')}</u>"
        else
          req.status.name
        end

      name.html_safe
    end
  end

  column(:project_order_name, header: 'name') do |req|
    format(req) do
      name = req.project_order_name.body.truncate(30)
      link_to(name, req)
    end
  end

  column(:sow, header: 'sow') do |req|
    format(req) do
      (render 'work_requests/main/sow_cell', work_request: req, default: req.default_sow).to_s
    end
  end

  column(:clients, header: 'clients') do |req|
    req.clients.map(&:name).join('<br/>').html_safe
  end

  column(:who_requested, header: 'who requested?') do |req|
    req.requester.name
  end

  column(:eta, header: 'eta') do |req|
    format(req) do |r|
      content_tag(
        :u, r.eta || '****-**-**',
        'id' => "eta_#{r.id}",
        'class' => 'mouse-hover',
        'data-container' => 'body',
        'data-toggle' => 'popover',
        'data-placement' => 'top',
        'data-html' => 'true',
        'data-content' => (render 'work_requests/main/index__date_form', key: 'eta', work_request: r).to_s
      )
    end
  end

  column(:last_invoice, header: 'last invoice') do |req|
    format(req) do |r|
      content_tag(
        :u, r.last_invoice || '****-**-**',
        'id' => "last_invoice_#{r.id}",
        'class' => 'mouse-hover',
        'data-container' => 'body',
        'data-toggle' => 'popover',
        'data-placement' => 'top',
        'data-html' => 'true',
        'data-content' => (render 'work_requests/main/index__date_form', key: 'last_invoice', work_request: r).to_s
      )
    end
  end
end
