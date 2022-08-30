# frozen_string_literal: true

class FactoidRequestsGrid
  include Datagrid

  # Scope
  scope { FactoidRequest.order(id: :desc) }

  # Filter
  filter(:requester)
  filter(:status, multiple: true)

  # Columns
  column(:id, order: false)

  priorities = Priority.all.each_with_object({}) do |p, hash|
    hash[p.name] = p.name.split(' - ').first
  end
  column(:priority) do |req|
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


  column(:name, order: false) do |req|
    format(req) do
      link_to(req.name, req)
    end
  end

  column(:agency) do |req|
    req.agency&.name
  end

  column(:opportunity) do |req|
    req.opportunity&.name
  end

  column(:who_requested, header: 'Who requested?') do |req|
    req.requester.name
  end
end
