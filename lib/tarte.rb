require 'tarte/baked_in_associations'
require 'tarte/baked_in_validation_helpers'

module Tarte
  def self.included(base)
    base.extend BakedInValidationHelpers
    base.extend BakedInAssociations
  end
end

ActiveRecord::Base.send(:include, Tarte)

# LEDO: Should I require haml? Where: gemspec, loading the plugin or the view helper?
module Tarte
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end