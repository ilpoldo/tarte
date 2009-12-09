require 'rubygems'
require 'activesupport'
require 'activerecord'

TEST_DATABASE_FILE = File.join(File.dirname(__FILE__), '..', 'test.sqlite3')
 
File.unlink(TEST_DATABASE_FILE) if File.exist?(TEST_DATABASE_FILE)

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", "database" => TEST_DATABASE_FILE
)
 
# RAILS_DEFAULT_LOGGER = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
 
load(File.dirname(__FILE__) + '/schema.rb')

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

#Mock ActiveRecord
# module ActiveRecord
#   class Base
#   end
# end

require 'tarte'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
