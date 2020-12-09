# frozen_string_literal: true

module DataSetsHelper # :nodoc:
  def developers_filter(data_set)
    data_set.story_types.where.not(developer: nil).map(&:developer).uniq.sort_by(&:name)
  end
end
