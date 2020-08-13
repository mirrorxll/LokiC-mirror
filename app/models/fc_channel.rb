# frozen_string_literal: true

class FcChannel < ApplicationRecord
  belongs_to :account, optional: true
end
