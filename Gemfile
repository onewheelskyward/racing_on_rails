source "https://rubygems.org"

gem "rails", "~>3.2"

gem "rake"
gem "authlogic"
gem "tabular", ">0.0.5"
gem "mysql2"
gem "pdf-reader", :require => "pdf/reader"
gem "Ascii85", :require => "ascii85"
gem "prawn", :git => "git://github.com/sandal/prawn.git"
gem "vestal_versions", :git => "git://github.com/scottwillson/vestal_versions.git", :branch => "rails_3_2"
gem "newrelic_rpm"
gem "erubis"
gem "will_paginate", "~> 3.0.beta"
gem "ruby-ole", :git => "git://github.com/scottwillson/ruby-ole.git"
gem "spreadsheet", :git => "git://github.com/scottwillson/spreadsheet.git"
gem "ckeditor", "3.7.2"
gem "paperclip"
gem "default_value_for", :git => "https://github.com/FooBarWidget/default_value_for.git"
gem "acts_as_list", :git => "git://github.com/swanandp/acts_as_list.git"
gem "acts_as_tree", :git => "git://github.com/parasew/acts_as_tree.git"
gem "dynamic_form"
gem "in_place_editing"
gem "ri_cal"
gem "truncate_html"
gem "jquery-rails"
gem "yui-compressor"
gem "bootstrap-sass", :git => "git://github.com/dszczyt/bootstrap-sass.git"
gem "jquery_datepicker"

group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "uglifier", ">= 1.0.3"
end

group :development do
  gem "capistrano"
  gem "capistrano-unicorn"
end

group :test do
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem "sqlite3"
  gem "timecop"
end

group :acceptance do
  gem "capybara"
  gem "database_cleaner"
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "launchy"
  gem "mocha", :require => false
  gem "selenium-webdriver"
  gem "timecop"
end

group :staging do
  gem "rvm-capistrano"
end

group :production do
  gem "airbrake"
  gem "syslog-logger"
  gem "unicorn"
  gem "execjs"
end
