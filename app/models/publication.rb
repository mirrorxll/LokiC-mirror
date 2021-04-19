# frozen_string_literal: true

class Publication < ApplicationRecord # :nodoc:
  belongs_to :client

  has_many :samples

  has_and_belongs_to_many :tags

  def tag?(tag)
    tags.to_a.map(&:pl_identifier).include?(tag.pl_identifier)
  end

  def self.all_mm_publications
    mm_clients = Client.where('name LIKE :like', like: 'MM -%')
    mm_pub_ids = mm_clients.map(&:publications).flat_map(&:to_a).map(&:id)

    where(id: mm_pub_ids)
  end
end
