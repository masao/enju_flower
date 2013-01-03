source 'https://rubygems.org'

gem 'rails', '3.2.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_core', '~> 0.1.1.pre2'
gem 'enju_biblio', '~> 0.1.0.pre13'
gem 'enju_library', '~> 0.1.0.pre6'
#gem 'enju_barcode', :git => 'git://github.com/nabeta/enju_barcode.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', '~> 0.1.0.pre7'
#gem 'enju_nii', '~> 0.1.0.pre2'
gem 'enju_oai', '~> 0.1.0.pre5'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', '~> 0.1.0.pre4'
#gem 'enju_purchase_request', '~> 0.1.0.pre5'
#gem 'enju_question', '~> 0.1.0.pre4'
gem 'enju_bookmark', '~> 0.1.2.pre7'
#gem 'enju_resource_merge', '~> 0.1.0.pre5'
#gem 'enju_circulation', '~> 0.1.0.pre9'
#gem 'enju_message', '~> 0.1.14.pre2'
#gem 'enju_inter_library_loan', '~> 0.1.0.pre5'
#gem 'enju_inventory', '~> 0.1.11.pre5'
#gem 'enju_event', '~> 0.1.17.pre6'
#gem 'enju_news', '~> 0.1.0.pre2'
gem 'enju_search_log', '~> 0.1.0.pre3'
gem 'enju_book_jacket', '~> 0.1.0.pre3'
gem 'enju_manifestation_viewer', '~> 0.1.0.pre3'
gem 'enju_export', '~> 0.1.1.pre2'

gem 'pg'
#gem 'mysql2', '~> 0.3'
#gem 'sqlite3'
gem 'ruby-prof', :group => [:development, :test]
gem 'zipruby'
gem 'kgio'

platforms :ruby_19 do
  gem 'simplecov', '~> 0.6', :require => false, :group => :test
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcpostgresql-adapter'
  #gem 'activerecord-jdbcmysql-adapter'
  gem 'rubyzip'
  gem 'trinidad', :require => false
end

gem 'exception_notification', '~> 3.0'
gem 'state_machine', '~> 1.1.2'
gem 'progress_bar'
gem 'inherited_resources', '~> 1.3'
gem 'strongbox'
gem 'dalli', '~> 2.6'
#gem 'sitemap_generator', '~> 3.4'
gem 'ri_cal'
gem 'paper_trail', '~> 2.7'
#gem 'recurrence'
#gem 'prism'
#gem 'money'
#gem 'RedCloth', '>= 4.2.9'
#gem 'extractcontent'
gem 'devise-encryptable'
#gem 'omniauth', '~> 1.1'
gem 'paperclip-meta'
gem 'aws-sdk'
#gem 'whenever', :require => false
#gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'geocoder'
gem 'client_side_validations', '~> 3.2'
gem 'simple_form', '~> 2.0'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
#gem 'oink', '>= 0.9.3'

group :development do
  gem 'parallel_tests', '~> 0.9'
  gem 'annotate', '~> 2.5'
  gem 'sunspot_solr', '~> 2.0.0.pre.120925'
  gem 'rails-erd'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.11'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'spork-rails'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.3'
  gem 'fakeweb'
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
gem 'jquery-ui-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
