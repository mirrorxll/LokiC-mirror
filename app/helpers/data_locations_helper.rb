# frozen_string_literal: true

module DataLocationsHelper # :nodoc:
  def domain_name(link, options = {})
    match = link[%r{https?:\/\/([^\/]+)}, 1]
    match ? link_to(match, link, options) : link
  end
end
