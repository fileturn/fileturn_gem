$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fileturn'
require 'rspec'
require 'ostruct'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  config.before(:each) do
    FileTurn.configure(:api_key => "67sFfjudMpXxJeioQcPSppYkoVdQD1oetqPWzMAh")
  end
end