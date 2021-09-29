# frozen_string_literal: true

namespace :lokic do
  desc 'create app account'
  task create_main_account: :environment do
    if Account.find_by(email: 'main@lokic.loc')
      puts 'Main LokiC account has already been created!'
      break
    end

    Account.create!(email: 'main@lokic.loc', password: '123456', first_name: 'LokiC', last_name: '')

    puts 'Main LokiC account created'
  end
end
