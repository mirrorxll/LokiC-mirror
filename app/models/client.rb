# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  belongs_to :author

  has_one :story_type_client_tag
  has_one :tag, through: :story_type_client_tag

  has_many :story_type_client_tags
  has_many :story_types, through: :story_type_client_tags

  has_many :publications

  has_and_belongs_to_many :sections
  has_and_belongs_to_many :tags

  def publications
    if name.eql?('Metric Media')
      mm_ids = Client.where('name LIKE :query', query: 'MM -%').pluck(:id)
      Publication.where(client_id: mm_ids)
    else
      Publication.where(client: self)
    end
  end
end
