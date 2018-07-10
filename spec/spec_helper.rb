$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fileturn'
require 'rspec'
require 'ostruct'
require 'vcr'
require 'stub_http_client'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  config.before(:each) do
    FileTurn.configure(:api_token => "51d5fc191b2b95f9278becf6b51fa347")
  end
end