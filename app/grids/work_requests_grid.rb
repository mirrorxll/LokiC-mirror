# frozen_string_literal: true

class WorkRequestsGrid
  include Datagrid

  # Scope
  scope { WorkRequest.order(id: :desc) }

  # Filter
  filter(:requester_id)
  filter(:archived)
  # Columns

  column(:id, order: false)

  priorities = Priority.all.each_with_object({}) do |p, hash|
    hash[p.name] = p.name.split(' - ').first
  end
  column(:priority, order: false) do |req|
    priorities[req.priority.name]
  end

  column(:status, html: true) do |req|
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

  column(:project_order_name, header: 'name', order: true) do |req|
    format(req) do
      name = req.project_order_name.body.truncate(30)
      link_to(name, req)
    end
  end

  column(:clients) do |req|
    req.clients.map(&:name).join('<br/>').html_safe
  end

  column(:who_requested, header: 'Who requested?') do |req|
    req.requester.name
  end

  column(:eta, header: 'ETA', order: false) do |req|
    format(req) do |r|
      content_tag(:div, id: "eta#{r.id}", class: 'text-center') do
        content_tag(
          :u, r.eta || '****-**-**',
          'class' => 'mouse-hover',
          'data-container' => 'body',
          'data-toggle' => 'popover',
          'data-placement' => 'top',
          'data-html' => 'true',
          'data-content' => (render 'work_requests/main/index__date_form', work_request: r, key: 'eta').to_s
        )
      end
    end
  end

  column(:last_invoice, order: false) do |req|
    format(req) do |r|
      content_tag(:div, id: "last_invoice#{r.id}", class: 'text-center') do
        content_tag(
          :u, r.last_invoice || '****-**-**',
          'class' => 'mouse-hover',
          'data-container' => 'body',
          'data-toggle' => 'popover',
          'data-placement' => 'top',
          'data-html' => 'true',
          'data-content' => (render 'work_requests/main/index__date_form', work_request: r, key: 'last_invoice').to_s
        )
      end
    end
  end

  column(:active_subtasks) do |req|
    # to do
  end
end
