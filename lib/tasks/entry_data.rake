# frozen_string_literal: true

require_relative '../assets/first_objects.rb'

namespace :db do
  desc 'Create user'
  task create_user: :environment do
    User.create(
      name: Rails.application.credentials.development[:tasks][:user_name],
      email: Rails.application.credentials.development[:tasks][:user_mail],
      password: Rails.application.credentials.development[:tasks][:user_pass]
    )

    puts 'User was created.'
  end

  desc 'Push couple of the test stories to db'
  task entry_data: :environment do
    FirstObjects.methods(false).sort.each do |method|
      class_name = method.to_s.split('_').map(&:capitalize).join
      eval("#{class_name}.create(FirstObjects.#{method})")
    end

    puts 'Data was entry.'
  end
end
