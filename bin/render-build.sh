bundle install
bundle exec rake assetes:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate