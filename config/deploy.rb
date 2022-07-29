# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :stages, %i[production staging]

set :user, 'app'
set :use_sudo, false

set :rvm_type, :user
set :rvm_ruby_version, '2.7.1'
set :rvm_custom_path, '/usr/local/rvm/'

set :pty, true
set :application, 'LokiC'
set :repo_url,    'git@github.com:localitylabs/LokiC.git'
set :branch,      'deploy'

set :deploy_via,              :remote_cache
set :puma_bind,               "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,              "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,                "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log,         "#{release_path}/log/puma.error.log"
set :puma_error_log,          "#{release_path}/log/puma.access.log"
set :puma_preload_app,        true
set :puma_worker_timeout,     nil
set :puma_init_active_record, true

append :linked_dirs, 'storage', 'public/ruby_code', 'public/uploads/images', 'log'
append :linked_files, 'config/master.key', 'config/google_drive.json'

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/deploy`
        puts 'WARNING: HEAD is not the same as origin/deploy'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  task :update_crontab do
    on roles(:app) do
      within current_path do
        execute "cd #{release_path} && RAILS_ENV=#{fetch(:stage)} bundle exec whenever --write-crontab"
      end
    end
  end

  before :starting,  :check_revision
  after  :finishing, :compile_assets
  after  :finishing, :cleanup
  after  :finishing, :restart
  after  :finishing, 'deploy:update_crontab'
end
