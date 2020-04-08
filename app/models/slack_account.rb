# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  serialize :profile, Hash
end
