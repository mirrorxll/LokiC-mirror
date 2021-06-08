# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_one :story_type_client_tag
  has_one :tag, through: :story_type_client_tag

  has_many :story_type_client_publication_tags
  has_many :story_types, through: :story_type_client_publication_tags

  has_and_belongs_to_many :sections
  has_and_belongs_to_many :tags

  def publications
    if name.eql?('Metric Media')
      mm = Client.where('name LIKE :like', like: 'MM -%')
      Publication.where(client: mm)
    else
      Publication.where(client: self)
    end
  end

  def statewide_publications
    publications.where(statewide: true)
  end

  def local_publications
    publications.where(statewide: false)
  end

end
