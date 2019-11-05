# frozen_string_literal: true

require_relative '../assets/story_obj.rb'

namespace :db do
  desc 'Create user'
  task create_user: :environment do
    User.create(
      name: Rails.application.credentials.development[:tasks][:user_name],
      email: Rails.application.credentials.development[:tasks][:user_mail],
      password: Rails.application.credentials.development[:tasks][:user_pass]
    )

    puts User.count.positive? ? 'OK' : "User wasn't added."
  end

  desc 'Push couple of the test stories to db'
  task push_stories: :environment do
    StorySamples.for_development.each do |story|
      Story.create!(
        name: story[:name],
        headline: story[:headline],
        body: story[:body],
        description: story[:description],
        writer: User.first
      )
    end

    puts Story.count.positive? ? 'OK' : 'No one stories were added.'
  end
end
