# frozen_string_literal: true

module DataSetsHelper # :nodoc:
  def domain_name(link, options = {})
    match = link[%r{https?:\/\/([^\/]+)}, 1]
    match ? link_to(match, link, options) : link
  end

  def source_keys
    [
      [:source_address, 'address'],
      [:source_explaining_data, 'explaining data'],
      [:source_release_frequency, 'release frequency'],
      [:source_scrape_frequency, 'scrape frequency']
    ]
  end

  def data_set_keys
    [
      [:location, 'location'],
      [:evaluation_document, 'evaluation document']
    ]
  end
end
