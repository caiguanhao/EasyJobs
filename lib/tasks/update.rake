namespace :update do
  desc 'Update EasyJobs to the latest version and rebuild all files for production.'
  task :all do
    Dir.chdir APP_ROOT
    system "git fetch --all"
    system "git reset --hard origin/master"
    system "RAILS_ENV=production rake db:migrate"
    system "RAILS_ENV=production rake assets:precompile"
    system "rake puma:restart"
  end
end
