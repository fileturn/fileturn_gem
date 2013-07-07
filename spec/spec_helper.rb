$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fileturn'
require 'rspec'
require 'ostruct'

RSpec.configure do |config|
  config.before(:each) do
    FileTurn.configure(:api_key => "67sFfjudMpXxJeioQcPSppYkoVdQD1oetqPWzMAh")
  end
end