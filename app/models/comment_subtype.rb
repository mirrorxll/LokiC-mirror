# frozen_string_literal: true

class CommentSubtype < ApplicationRecord
  has_many :comments, foreign_key: :subtype_id
end
