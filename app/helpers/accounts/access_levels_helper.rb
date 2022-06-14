# frozen_string_literal: true

module Accounts
  module AccessLevelsHelper
    def permissions_keys(branch, form, hash)
      content_tag(:ul, class: 'mb-2') do
        html = []

        hash.each do |access, value|
          html << content_tag(:li) do
            key = content_tag(:p, "#{access.humanize}:", class: 'm-0')
            value.is_a?(Hash) ? (key + permissions_keys(branch, form, value)) : key
          end
        end

        html.join.html_safe
      end
    end

    def permissions_values(branch, form, hash)
      content_tag(:ul, style: 'list-style-type: none;', class: 'mb-2 pl-0') do
        html = []

        hash.each do |access, value|
          html << content_tag(:li) do
            case value
            when Hash
              form.check_box("#{branch}[#{access}]") + permissions_values(branch, form, value)
            when Array
              value.map do |v|
                content_tag(:div, class: 'form-check form-check-inline') do
                  (form.check_box("#{branch}[#{access}]", class: 'form-check-input') +
                    form.label("#{branch}[#{access}]", v, class: 'form-check-label')).html_safe
                end
              end.join.html_safe
            else
              form.check_box("#{branch}[#{access}]")
            end
          end
        end

        html.join.html_safe
      end
    end
  end
end
