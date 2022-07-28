# frozen_string_literal: true

namespace :topics do
  desc "Filling 'kinds' table"
  task filling_kinds: :environment do
    %w[Person Organization Geo].each do |kind|
      parent_kind = Kind.find_or_create_by(name: kind, parent_kind_id: nil)
      if kind.eql?('Geo')
        %w[State County CongressionalDistrict ElementarySchoolDistrict Precinct
           SecondarySchoolDistrict City StateHouseDistrict StatePrecinct StateSenateDistrict
           Township UnifiedSchoolDistrict Ward Zip].each do |geo_kind|
          parent_kind.sub_kinds << Kind.find_or_create_by(name: geo_kind, parent_kind_id: parent_kind.id)
        end
      else
        parent_kind.sub_kinds << Kind.find_or_create_by(name: kind, parent_kind_id: parent_kind.id)
      end
    end
  end

  desc 'Actualize internal topics with Limpar'
  task update_topics: :environment do
    TopicsJob.new.perform
  end
end
