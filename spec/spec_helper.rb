$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

#Mock ActiveRecord
module ActiveRecord
  class Base
  end
end

require 'tarte'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
