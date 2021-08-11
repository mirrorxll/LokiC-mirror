# frozen_string_literal: true

class Client < ApplicationRecord # :nodoc:
  has_many :story_type_client_publication_tags
  has_many :story_types, through: :story_type_client_publication_tags

  has_many :clients_tags, class_name: 'ClientTag'
  has_many :tags, through: :clients_tags
  has_many :tags_for_all_pubs, -> { where('for_all_pubs = ?', true) }, through: :clients_tags, source: :tag
  has_many :tags_for_local_pubs, -> { where('for_local_pubs = ?', true) }, through: :clients_tags, source: :tag
  has_many :tags_for_statewide_pubs, -> { where('for_statewide_pubs = ?', true) }, through: :clients_tags, source: :tag

  has_and_belongs_to_many :sections

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

  def tags_for(publication)
    if publication.nil? || publication.name == 'all publications'
      (tags.order(:name) & tags_for_all_pubs).map { |tag| [tag.name, tag.id] }
    elsif publication.name == 'all local publications'
      (tags.order(:name) & tags_for_local_pubs).map { |tag| [tag.name, tag.id] }
    elsif publication.name == 'all statewide publications'
      (tags.order(:name) & tags_for_statewide_pubs).map { |tag| [tag.name, tag.id] }
    else
      publication.tags.order(:name).map { |tag| [tag.name, tag.id] }
    end
  end

  def tags_not_for(publication)
    if publication.nil? || publication.name == 'all publications'
      (tags.order(:name) - tags_for_all_pubs).map { |tag| [tag.name, tag.id] }
    elsif publication.name == 'all local publications'
      (tags.order(:name) - tags_for_local_pubs).map { |tag| [tag.name, tag.id] }
    elsif publication.name == 'all statewide publications'
      (tags.order(:name) - tags_for_statewide_pubs).map { |tag| [tag.name, tag.id] }
    else
      publication.tags.order(:name).map { |tag| [tag.name, tag.id] }
    end
  end

end
