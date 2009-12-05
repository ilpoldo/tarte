require 'tarte/model_methods'

# LEDO: Should I require haml? Where: gemspec, loading the plugin or the view helper?
module TARTE
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end