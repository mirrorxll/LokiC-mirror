# frozen_string_literal: true

require_relative '../assets/first_objects.rb'

namespace :db do
  desc 'Push couple of the test stories to db'
  task entry_data: :environment do
    User.create!(
      name: 'Init User',
      email: 'loki.c@dev.loc',
      password: '123456'
    )

    FirstObjects.methods(false).sort.each do |method|
      class_name = method.to_s.split('_').map(&:capitalize).join
      eval("#{class_name}.create(FirstObjects.#{method})")
    end
    puts 'Data was entry.'
  end

  desc 'create user'
  task :create_user, %i[name email pass] => :environment do |t, args|
    User.create!(
      name: args['name'],
      email: args['email'],
      password: args['pass']
    )
    puts 'User was created.'
  end

end
