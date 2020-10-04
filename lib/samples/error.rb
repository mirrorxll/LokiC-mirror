# frozen_string_literal: true

module Samples
  class Error < StandardError; end

  class LeadPostError < Error; end
  class StoryPostError < Error; end
end
