source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_barcode', '~> 0.0.3'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
#gem 'enju_ndl', '~> 0.0.24'
#gem 'enju_nii', '~> 0.0.4'
gem 'enju_oai', '~> 0.0.3'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', '~> 0.0.14'
#gem 'enju_purchase_request', '~> 0.0.9'
#gem 'enju_question', '~> 0.0.16'
gem 'enju_bookmark', '~> 0.0.17'
#gem 'enju_resource_merge', '~> 0.0.8'
#gem 'enju_circulation', '~> 0.0.46'
#gem 'enju_message', '~> 0.0.23'
#gem 'enju_inter_library_loan', '>= 0.0.4'
#gem 'enju_inventory', '~> 0.0.9'
#gem 'enju_event', '~> 0.0.21'
#gem 'enju_news', :git => 'git://github.com/nabeta/enju_news.git'
gem 'enju_search_log', '~> 0.0.5'
gem 'enju_book_jacket', :git => 'git://github.com/nabeta/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/nabeta/enju_manifestation_viewer.git'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.6', :require => false, :group => :test
end

platforms :ruby_18 do
  gem 'system_timer'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
  gem 'rubyzip2'
  gem 'glassfish'
end

gem 'fastercsv' if RUBY_VERSION < '1.9'

gem 'will_paginate', '~> 3.0'
gem 'exception_notification', '~> 2.6'
gem 'configatron'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'state_machine', '~> 1.1.2'
gem 'sunspot_rails', '~> 2.0.0.pre.120417'
gem 'progress_bar'
gem 'friendly_id', '~> 4.0'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'marc'
#gem 'attr_encryptor'
gem 'dalli', '~> 2.0'
gem 'sitemap_generator', '~> 3.1'
gem 'ri_cal'
gem 'paper_trail', '~> 2.6'
#gem 'recurrence'
#gem 'prism'
#gem 'money'
gem 'RedCloth', '>= 4.2.9'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
#gem 'extractcontent'
gem 'cancan', '>= 1.6.7'
gem 'devise', '~> 2.1'
gem 'devise-encryptable'
#gem 'omniauth', '~> 1.1'
gem 'addressable'
gem 'paperclip', '~> 2.7'
gem 'paperclip-meta'
gem 'aws-sdk', '~> 1.4'
gem 'whenever', :require => false
#gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
#gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'attribute_normalizer', '~> 1.1'
#gem 'geokit'
gem 'geocoder'
gem 'acts_as_list', '~> 0.1.6'
gem 'library_stdnums'
gem 'client_side_validations', '~> 3.2.0.beta.3'
gem 'simple_form', '~> 2.0'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
#gem 'oink', '>= 0.9.3'

group :development do
  gem 'parallel_tests', '~> 0.8'
  gem 'annotate', '~> 2.4.1.beta1'
  gem 'sunspot_solr', '~> 2.0.0.pre.120417'
  gem 'rails-erd'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.10'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'spork-rails'
#  gem 'rcov', '0.9.11'
#  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.2'
  gem 'fakeweb'
#  gem 'churn', '0.0.13'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
