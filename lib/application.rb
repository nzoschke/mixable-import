require 'bundler'
Bundler.require

# TODO: Sequel extension is looking for lib/sequel/extensions explicitly, so need to alter path?
$:.unshift File.dirname(__FILE__)
require_relative 'initializer'
