source 'http://rubygems.org'

gem 'rails', '3.0.4'

# Bundle edge Rails instead:
#gem 'rails', :git => 'git://github.com/rails/rails.git'

platforms :ruby do
  gem 'pg'
  gem 'ruby-prof', :group => [:development, :test]
end

platforms :ruby_19 do
  gem 'simplecov', :require => false, :group => :test
end

platforms :ruby_18 do
  gem 'system_timer'
end

platforms :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
end

gem 'fastercsv' if RUBY_VERSION < '1.9'

gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
gem 'exception_notification', :git => 'git://github.com/rails/exception_notification.git', :require => 'exception_notifier'
gem 'delayed_job', '>=2.1.3'
gem 'state_machine'
gem 'prawn'
gem 'sunspot_rails', '>=1.2.1'
gem 'friendly_id'
gem 'nokogiri'
gem 'acts-as-taggable-on'
gem 'dalli'
gem 'file_wrapper'
gem 'paper_trail', '>=2.0.0'
gem 'rails-geocoder', :require => 'geocoder'
gem 'isbn-tools', :require => 'isbn/tools'
gem 'attribute_normalizer'
gem 'configatron'
gem 'extractcontent'
gem 'cancan', '>=1.5.1'
gem 'devise'
gem 'omniauth'
gem 'paperclip'
gem 'dynamic_form'
gem 'formtastic'
gem 'jquery-rails'
gem 'sanitize'
gem 'zipruby'
gem 'formatize'
gem 'barby'
gem 'prawnto'

gem 'oink'
gem 'parallel_tests', :group => :development

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'autotest'
  gem 'autotest-rails'
  gem 'factory_girl_rails'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
