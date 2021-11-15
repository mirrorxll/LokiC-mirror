# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :commentator, class_name: 'Account', optional: true

  has_many :assignments, class_name: 'CommentAssignment'
  has_many :assignment_to, through: :assignments, source: :account

  def assignment?
    !assignment_to.empty?
  end

  def assignment_to_s
    assignment_to.map { |assignment| assignment.name }.to_sentence
  end
end
