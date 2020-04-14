# frozen_string_literal: true

module DataSetsHelper # :nodoc:
  def domain_name(link, options = {})
    match = link[%r{https?:\/\/([^\/]+)}, 1]
    match ? link_to(match, link, options) : link
  end

  def src_keys
    [
      [:src_address, 'address'],
      [:src_explaining_data, 'explaining data'],
    ]
  end

  def data_set_keys
    [
      [:location, 'location'],
      [:evaluation_document, 'evaluation document']
    ]
  end
end
