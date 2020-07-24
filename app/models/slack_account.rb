# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  serialize :profile, Hash

  belongs_to :account, optional: true
end
