# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_one :story_type_client_tag
  has_one :tag, through: :story_type_client_tag

  has_many :story_type_client_tags
  has_many :story_types, through: :story_type_client_tags

  has_many :publications

  has_and_belongs_to_many :sections
  has_and_belongs_to_many :tags

  def self.all_mm_publications
    mm_clients = where('name LIKE :like', like: 'MM -%')
    mm_pub_ids = mm_clients.map(&:publications).flat_map(&:to_a).map(&:id)

    Publication.where(id: mm_pub_ids)
  end
end
