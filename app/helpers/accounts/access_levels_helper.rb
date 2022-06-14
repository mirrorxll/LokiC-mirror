module Accounts
  module AccessLevelsHelper
    def permissions_table(form, hash, prefix = '', deep = 0)
      content_tag(:ul) do
        hash.map do |key, access|
          raw_prefix =
            case deep
            when 0
              "#{prefix}[%%%]"
            else
              pos = prefix.index(']')
              "#{prefix}".insert(pos, '[%%%]')
            end
          container = raw_prefix.sub(/%{3}/, key)

          content_tag(:li) do

            row = form.label(container, class: 'form-check-label w-100') do
              content_tag(:div, class: 'btn-light', style: 'display: flex; justify-content: space-between;') do
                title = content_tag(:span, key.humanize.downcase)
                content = content_tag(:div, class: 'form-check form-check-inline') do
                  form.check_box(container, class: 'form-check-input', style: 'margin-right: 120px;')
                end

                title + content
              end
            end
            sub_ul = access.is_a?(Hash) ? permissions_table(form, access, container, deep + 1) : ''

            (row + sub_ul)
          end
        end.reduce(:+)
      end
    end
  end
end
