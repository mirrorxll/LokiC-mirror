# frozen_string_literal: true

namespace :user do
  desc 'create a new user'
  task create: :environment do
    print 'account type: '
    a_type = STDIN.gets.chomp

    print 'first name: '
    f_name = STDIN.gets.chomp
    print 'last_name: '
    l_name = STDIN.gets.chomp
    print 'email: '
    email = STDIN.gets.chomp

    pass1 = nil
    loop do
      print 'password: '
      pass1 = STDIN.gets.chomp
      print 'pass confirmation: '
      pass2 = STDIN.gets.chomp

      break if pass1.eql?(pass2)

      puts "Passwords don't match. Try again."
    end

    type = AccountType.find_by(name: a_type)
    Account.create!(account_type: type, first_name: f_name, email: email, last_name: l_name, password: pass1)
  end
end
