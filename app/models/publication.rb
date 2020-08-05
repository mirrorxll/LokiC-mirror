# frozen_string_literal: true

class Publication < ApplicationRecord # :nodoc:
  belongs_to :client

  has_many :samples

  has_and_belongs_to_many :tags

  def tag?(tag)
    tags.to_a.map(&:pl_identifier).include?(tag.pl_identifier)
  end
end
