source "http://rubygems.org"

gemspec

gem 'redis-slave', :git => "git://github.com/deadlyicon/redis-slave.git"

group :development do

  platform :ruby_18 do
    gem "ruby-debug"
  end

  platform :ruby_19 do
    gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
    gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
    gem "ruby-debug19"
  end

  gem 'shotgun'

  gem 'capistrano'
  gem 'rvm-capistrano'
end

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'resque_unit'
  gem 'thin'
end

gem 'unicorn'
