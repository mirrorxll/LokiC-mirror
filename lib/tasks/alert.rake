# frozen_string_literal: true

namespace :alert do
  desc 'fill history events'
  task fill_alerts: :environment do
    subtypes = [
      'population',
      'export configuration',
      'creation',
      'manual-scheduling',
      'backdate-scheduling',
      'auto-scheduling',
      'run-from-code-scheduling',
      'export',
      'remove from pl',
      'crontab',
      'reminder'
    ]

    subtypes.each { |subtype| AlertSubtype.find_or_create_by!(name: subtype) }
  end

  desc '12345'
  task replace_subtype: :environment do
    Alert.all.each do |a|
      st = AlertSubtype.find_or_create_by!(name: a.subtype)
      a.update(subtype_id: st.id)
    end
  end
end
