# frozen_string_literal: true

require_relative '../assets/first_objects.rb'

namespace :db do
  desc 'Push couple of the test stories to db'
  task entry_data: :environment do
    User.create!(
      name: 'Initial User',
      email: 'loki-c@dev.com',
      password: '123456'
    )
    puts 'User was created.'

    FirstObjects.methods(false).sort.each do |method|
      class_name = method.to_s.split('_').map(&:capitalize).join
      eval("#{class_name}.create(FirstObjects.#{method})", __FILE__, __LINE__)
    end
    puts 'Data was entry.'
  end

  desc 'Create User'
  task :create_user, %i[name email password] => :environment do |t, args|
    User.create!(
      name: args['name'],
      email: args['email'],
      password: args['password']
    )
  end
end
