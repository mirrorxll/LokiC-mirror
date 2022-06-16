# frozen_string_literal: true

module Accounts
  module AccessLevelsHelper
    def permissions_table(hash, deep = 0)
      content_tag(:ul) do
        hash.map do |key, access|

          content_tag(:li) do
            row = content_tag(:div, class: 'btn-light', style: 'display: flex; justify-content: space-between;') do
              title = content_tag(:span, key.humanize.downcase)
              content =
                if access.class.in?([TrueClass, FalseClass])
                  icon = access ? 'check' : 'times'
                  content_tag(:span, icon('fa', icon), class: 'd-inline-block', style: 'width: 120px;')
                else
                  content_tag(:span, '&#8203;'.html_safe)
                end

              title + content
            end
            sub_ul = access.is_a?(Hash) ? permissions_table(access, deep + 1) : ''

            (row + sub_ul)
          end
        end.reduce(:+)
      end
    end

    def permissions_form(form, hash, disabled = true, prefix = '', deep = 0)
      content_tag(:ul) do
        hash.map do |key, access|
          raw_prefix =
            deep.zero? ? "#{prefix}[%%%]" : String.new(prefix).insert(prefix.index(']'), '[%%%]')
          container = raw_prefix.sub(/%{3}/, key)

          content_tag(:li) do
            row = form.label(container, class: 'form-check-label w-100') do
              content_tag(:div, class: 'btn-light', style: 'display: flex; justify-content: space-between;') do
                title = content_tag(:span, key.humanize.downcase)
                content =
                  if access.class.in?([TrueClass, FalseClass])
                    content_tag(:div, class: 'form-check form-check-inline') do
                      form.check_box(
                        container,
                        class: 'form-check-input',
                        style: 'margin-right: 120px;',
                        checked: access,
                        disabled: disabled
                      )
                    end
                  else
                    content_tag(:span, '&#8203;'.html_safe)
                  end

                title + content
              end
            end
            sub_ul = access.is_a?(Hash) ? permissions_form(form, access, disabled, container, deep + 1) : ''

            (row + sub_ul)
          end
        end.reduce(:+)
      end
    end
  end
end
