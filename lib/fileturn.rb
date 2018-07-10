module FileTurn
  extend self

  attr_reader :api_token

  def configure(params={})
    raise ArgumentError, "missing params (api_token)" if params[:api_token].nil?
    @api_token = params[:api_token]
  end
end

require 'recursive-open-struct'
require "fileturn/errors"
require "fileturn/http_client"
require "fileturn/resources/resource"
require "fileturn/resources/account"
require "fileturn/resources/upload"
require "fileturn/resources/conversion"