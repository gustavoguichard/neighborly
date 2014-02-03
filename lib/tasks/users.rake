###
# Task to manage the application users
##
namespace :users do
  ###
  # Sets user as administrator
  # usage: rake users:admin[email]
  ##
  desc "Sets user as administrator"
  task :admin, [:email] => :environment do |t, args|
    puts
    puts "Setting #{args[:email]} as administrator..."
    u = User.find_by_email(args[:email])
    unless u
      puts "ERROR: User doesn't exist!"
    next
    end

    u.update_attribute :admin, true
    puts  "#{u.name}: #{u.email} is now an administrator!"
    puts 'Done!'
    puts
  end

  ###
  # Sets first user as administrator
  # usage: rake users:adminfirst
  ##
  desc "Sets first user as administrator"
  task :adminfirst => :environment do
    puts
    unless User.count > 0
      puts "ERROR: User doesn't exist!"
    next
    end

    u = User.first
    u.update_attribute :admin, true
    puts  "#{u.name}: #{u.email} is now an administrator!"
    puts 'Done!'
    puts
  end
end
