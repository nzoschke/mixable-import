require 'bundler'
Bundler.require

# TODO: Sequel extension is looking for lib/sequel/extensions explicitly, so need to alter path?
$:.push File.dirname(__FILE__)

require_relative 'initializer'
