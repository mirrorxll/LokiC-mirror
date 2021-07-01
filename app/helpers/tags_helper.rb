# frozen_string_literal: true

module TagsHelper
  def tags_for_publication(publication, client)
    name_pubs, for_all, not_for_all =
      if publication.nil? || publication.name == 'all publications'
        ['for all pubs',
         (client.tags.order(:name) & client.tags_for_all_pubs).map { |tag| [tag.name, tag.id] },
         (client.tags.order(:name) - client.tags_for_all_pubs).map { |tag| [tag.name, tag.id] }]
      elsif publication.name == 'all local publications'
        ['for all local pubs',
         (client.tags.order(:name) & client.tags_for_local_pubs).map { |tag| [tag.name, tag.id] },
         (client.tags.order(:name) - client.tags_for_local_pubs).map { |tag| [tag.name, tag.id] }]
      elsif publication.name == 'all statewide publications'
        ['for all statewide pubs',
         (client.tags.order(:name) & client.tags_for_statewide_pubs).map { |tag| [tag.name, tag.id] },
         (client.tags.order(:name) - client.tags_for_statewide_pubs).map { |tag| [tag.name, tag.id] }]
      else
        [ "for #{publication.name}", publication.tags.order(:name).map { |tag| [tag.name, tag.id] } ]
      end
    group_tags(name_pubs, for_all, not_for_all)
  end

  def group_tags(name_pubs, for_all = nil, not_for_all = nil)
    if for_all.blank?
      [ [ 'not for all', not_for_all ] ]
    elsif not_for_all.blank?
      [ [ name_pubs, for_all ] ]
    elsif !['for all pubs', 'for all local pubs', 'for all statewide pubs'].include? name_pubs
      [ [ name_pubs, for_all ] ]
    else
      [ [ name_pubs, for_all ], [ 'not for all', not_for_all ] ]
    end
  end
end
