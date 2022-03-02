# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'dotenv-rails'

gem 'rails_admin', git: 'https://github.com/sferik/rails_admin.git'

# front-end
gem 'devise'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'font-awesome-sass', '~> 5.12.0'
gem 'pretender'
# background jobs
gem 'sidekiq', '6.0.5'
gem 'sidekiq-scheduler', '3.0.1'
# slack-api
gem 'slack-ruby-client'
# haml's engine
gem 'haml-rails', '~> 2.0'
# pagination
gem 'kaminari'
# Displaying ruby code
gem 'coderay'
# Spreadsheets
gem 'rubyXL'
# google
gem 'google-api-client', '~> 0.34'
gem 'google_drive'
# build and represent table-like data
gem 'datagrid'

# mini_loki_c gems
gem 'svg-graph', '2.2.0' # don't change version as long as it is possible! :)
gem 'pg', '1.3.3'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '<= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '4.1.4'
# Use Active Storage variant
gem 'image_processing', '~> 1.2'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capistrano', '3.14.1', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-yarn', require: false
  gem 'ed25519', '>= 1.2', '< 2.0'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
