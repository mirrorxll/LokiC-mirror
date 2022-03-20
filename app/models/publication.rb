# frozen_string_literal: true

class Publication < ApplicationRecord # :nodoc:
  belongs_to :client

  has_many :stories

  has_many :opportunity_publications, -> { where(archived_at: nil) }
  has_many :opportunities, through: :opportunity_publications

  has_and_belongs_to_many :tags

  def tag?(tag)
    tags.to_a.map(&:pl_identifier).include?(tag.pl_identifier)
  end

  def mm_or_lgis?
    client.name.match?(/MM -/) || client.name.eql?('LGIS')
  end

  def mb?
    client.name.eql?('Metro Business Network')
  end
end
