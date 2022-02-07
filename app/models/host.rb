# frozen_string_literal: true

class Host < ApplicationRecord
  has_many :schemas, dependent: :destroy
end
