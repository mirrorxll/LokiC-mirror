# frozen_string_literal: true

class WorkRequestsGrid
  include Datagrid

  # Scope
  scope { WorkRequest.order(id: :desc) }

  accounts = Account.all.map { |a| [a.name, a.id] }
  filter(:requester, :default, select: accounts) do |value, scope|
    scope.where(requester_id: value)
  end

  # Columns
  priorities = Priority.all.each_with_object({}) do |p, hash|
    hash[p.name] = p.name.split(' - ').first
  end
  column(:priority) do |req|
    priorities[req.priority.name]
  end

  # column(:work_types) do |req|
  #   format(req) do |r|
  #     flag = false
  #
  #     names = r.work_types.map { |wt| "- #{wt.name}" }
  #     truncated = names.map do |n|
  #       if n.length > 30
  #         flag = true
  #         n.truncate(30)
  #       else
  #         n
  #       end
  #     end
  #
  #     names_html = content_tag(:div, names.join('<br/>').html_safe, class: 'text-left')
  #     truncated_html = truncated.join('<br/>').html_safe
  #
  #     attrs =
  #       if flag
  #         {
  #           'data-toggle' => 'tooltip',
  #           'data-placement' => 'right',
  #           'data-html' => 'true',
  #           'title' => names_html
  #         }
  #       else
  #         {}
  #       end
  #
  #     content_tag(:div, link_to(truncated_html, r), attrs)
  #   end
  # end

  column(:clients) do |req|
    req.clients.map(&:name).join('<br/>').html_safe
  end

  # column(:project_order_name) do |req|
  #   format(req) do
  #     name = req.project_order_name.body
  #     truncated = name.truncate(30)
  #     lnk = req.sow&.strip&.present? ? link_to(truncated, req.sow, target: '_blank') : truncated
  #     attrs = { 'data-toggle' => 'tooltip', 'data-placement' => 'right', 'data-html' => 'true', 'title' => name }
  #
  #     content_tag(:div, lnk, attrs)
  #   end
  # end

  column(:who_requested, header: 'Who requested?') do |req|
    req.requester.name
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

  column(:eta, header: 'ETA') do |req|
    format(req) do |r|
      content_tag(:div, id: "eta#{r.id}", class: 'text-center') do
        content_tag(
          :u, r.eta || '****-**-**',
          'class' => 'mouse-hover',
          'data-container' => 'body',
          'data-toggle' => 'popover',
          'data-placement' => 'top',
          'data-html' => 'true',
          'data-content' => (render 'work_requests/index__date_form', work_request: r, key: 'eta').to_s
        )
      end
    end
  end

  # column(:r_val, header: 'R Value', mandatory: true) do |req|
  #   format(req) do |r|
  #     content_tag(:div, id: "r_val#{r.id}", class: 'text-center') do
  #       content_tag(
  #         :u, r.r_val || '**',
  #         'class' => 'mouse-hover',
  #         'data-container' => 'body',
  #         'data-toggle' => 'popover',
  #         'data-placement' => 'top',
  #         'data-html' => 'true',
  #         'data-content' => (render 'work_requests/index__number_form', work_request: r, key: 'r_val').to_s
  #       )
  #     end
  #   end
  # end

  # column(:f_val, header: 'F Value', mandatory: true) do |req|
  #   format(req) do |r|
  #     content_tag(:div, id: "f_val#{r.id}", class: 'text-center') do
  #       content_tag(
  #         :u, r.f_val || '**',
  #         'class' => 'mouse-hover',
  #         'data-container' => 'body',
  #         'data-toggle' => 'popover',
  #         'data-placement' => 'top',
  #         'data-html' => 'true',
  #         'data-content' => (render 'work_requests/index__number_form', work_request: r, key: 'f_val').to_s
  #       )
  #     end
  #   end
  # end

  # column(:first_invoice, header: 'First invoice due')
  # column(:final_invoice, header: 'Final invoice due')
  column(:last_invoice) do |req|
    format(req) do |r|
      content_tag(:div, id: "last_invoice#{r.id}", class: 'text-center') do
        content_tag(
          :u, r.last_invoice || '****-**-**',
          'class' => 'mouse-hover',
          'data-container' => 'body',
          'data-toggle' => 'popover',
          'data-placement' => 'top',
          'data-html' => 'true',
          'data-content' => (render 'work_requests/index__date_form', work_request: r, key: 'last_invoice').to_s
        )
      end
    end
  end

  column(:active_subtasks) do |req|
    # to do
  end
end
