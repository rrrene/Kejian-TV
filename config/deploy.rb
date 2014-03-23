require 'pry'

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'Kejian-TV'
set :repo_url, 'git@github.com:Kejian-TV/Kejian-TV.git'
set :branch, :four
set :deploy_to, '/home/psvr/kejian-tv'
set :linked_files, %w{config/database.yml config/keys.yml config/newrelic.yml config/settings.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

namespace :deploy do

  task :qrsync do
    on roles(:app), in: :sequence, wait: 5 do
      execute "/usr/local/bin/qrsync /etc/kejian_tv_four.yml"
    end
  end
  after 'deploy:compile_assets', 'deploy:qrsync'

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :kill, "-USR1 `cat /home/psvr/kejian-tv/shared/tmp/pids/puma.pid`"
    end
  end
  # after 'deploy:publishing', 'deploy:restart'
    
end

# operation and maintenance
namespace :onm do
  
  desc "Report Uptimes"
  task :uptime do
    on roles(:all) do |host|
      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
    end
  end  

  desc 'Start application'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, "exec puma --config /home/psvr/kejian-tv/shared/config/puma.rb"
      end
    end
  end
  
  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute :kill, "-INT `cat /home/psvr/kejian-tv/shared/tmp/pids/puma.pid`"
    end
  end
  
end

