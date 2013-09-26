namespace :deploy do
  # You need a remote git called production, the deploy is made from production
  # branch to master.
  desc 'Deploy the app to production'
  task :production do
    system "git push production production:master"
  end

  # You need a remote git called staging, the deploy is made from master
  # branch to master.
  desc 'Deploy the app to staging'
  task :staging do
    system "git push staging master:master"
  end
end
