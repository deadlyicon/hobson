require 'rubygems'
require 'bundler/setup'
require File.expand_path('../lib/hobson', __FILE__)

Hobson.log_to_stdout!
Hobson.log_redis!
run Hobson::Server
