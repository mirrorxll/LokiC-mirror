# frozen_string_literal: true

class CommentAssignment < ApplicationRecord # :nodoc:
  belongs_to :comment
  belongs_to :account
end
