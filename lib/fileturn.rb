module FileTurn
  extend self

  attr_reader :api_token

  def configure(params={})
    @api_token = params[:api_token] || ENV['FILETURN_TOKEN']
    raise ArgumentError, "missing params (api_token)" if @api_token.nil?
  end
end

require 'recursive-open-struct'
require "fileturn/errors"
require "fileturn/http_client"
require "fileturn/resources/resource"
require "fileturn/resources/account"
require "fileturn/resources/upload"
require "fileturn/resources/conversion"
