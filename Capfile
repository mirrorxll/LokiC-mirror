require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/puma'
require 'capistrano/scm/git'
require 'capistrano/yarn'

install_plugin Capistrano::SCM::Git

install_plugin Capistrano::Puma # Default puma tasks
install_plugin Capistrano::Puma::Daemon

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
