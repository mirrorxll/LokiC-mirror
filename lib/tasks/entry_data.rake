# frozen_string_literal: true

require_relative '../assets/first_objects.rb'

namespace :db do
  desc 'Push couple of the test story_types to db'
  task entry_data: :environment do
    FirstObjects.account_type.each { |obj| AccountType.create!(obj)}
    FirstObjects.account.each { |obj| Account.create!(obj) }
    FirstObjects.data_set.each { |obj| DataSet.create!(obj) }
    FirstObjects.story_type.each { |obj| StoryType.create!(obj) }
    FirstObjects.client.each { |obj| Client.create!(obj) }
    FirstObjects.publication.each { |obj| Publication.create!(obj) }
    FirstObjects.section.each { |obj| Section.create!(obj) }
    FirstObjects.tag.each { |obj| Tag.create!(obj) }
    FirstObjects.photo_bucket.each { |obj| PhotoBucket.create!(obj) }
    FirstObjects.level.each { |obj| Level.create!(obj) }
    FirstObjects.frequency.each { |obj| Frequency.create!(obj) }

    puts 'Data was entry.'
  end

  desc 'create account'
  task :create_account, %i[name email pass] => :environment do |t, args|
    Account.create!(
      first_name: args['first_name'],
      last_name: args['last_name'],
      email: args['email'],
      password: args['pass']
    )

    puts 'Account was created.'
  end
end
