Version:
ruby version 3.3.7
rails version 7.1.5

Setup:
setup ruby 3.3.7
gem install bundler
gem install rails -v 7.1.5
bundle install
rails db:create
rails db:migrate
rails db:seed
rails tmp:cache:clear(for windows)
rails s


