# config valid for current version and patch releases of Capistrano
lock '~> 3.14.0'

set :stage, :production

server 'app@loki01.locallabs.com', port: 22, roles: %i[web app db], primary: true
set :use_sudo, false

set :rvm_type, :user
set :rvm_ruby_version, '2.6.3'
set :rvm_custom_path, '/usr/local/rvm/'

set :pty, true
set :application, 'LokiC'
set :repo_url, 'git@github.com:mirrorxll/LokiC-mirror.git'
ask :branch, 'deploy'

set :deploy_via,              :remote_cache
set :deploy_to,               '/home/app/LokiC'
set :puma_workers,            8
set :puma_threads,            [8, 16]
set :puma_bind,               "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,              "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,                "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log,         "#{release_path}/log/puma.error.log"
set :puma_error_log,          "#{release_path}/log/puma.access.log"
set :puma_preload_app,        true
set :puma_worker_timeout,     nil
set :puma_init_active_record, true

namespace :sidekiq do
  task :restart do
    invoke 'sidekiq:stop'
    invoke 'sidekiq:start'
  end

  before 'deploy:finished', 'sidekiq:restart'

  task :stop do
    on roles(:app) do
      within current_path do
        execute'tmux send-keys -t sidekiq-tmux.0 ^C ENTER'
      end
    end
  end

  task :start do
    on roles(:app) do
      within current_path do
        execute "tmux send-keys -t sidekiq-tmux.0 'bundle exec sidekiq -e #{fetch(:stage)} -C config/sidekiq.yml' ENTER"
      end
    end
  end
end

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

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end