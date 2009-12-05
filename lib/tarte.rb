require 'tarte/baked_in_associations'
ActiveRecord::Base.send(:include, Tarte)

# LEDO: Should I require haml? Where: gemspec, loading the plugin or the view helper?
module Tarte
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end