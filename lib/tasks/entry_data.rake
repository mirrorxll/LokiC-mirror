# frozen_string_literal: true

require_relative '../assets/first_objects.rb'

namespace :db do
  desc 'Push couple of the test stories to db'
  task entry_data: :environment do
    User.create!(
      first_name: 'Sergey',
      last_name: 'Emelyanov',
      account_type: 'admin',
      email: 'evilx@loki.com',
      password: '123456'
    )

    FirstObjects.methods(false).sort.each do |method|
      class_name = method.to_s.split('_').map(&:capitalize).join
      puts method
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
