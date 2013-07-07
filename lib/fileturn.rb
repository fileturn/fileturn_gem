module FileTurn
  extend self

  attr_reader :api_key

  def configure(params={})
    raise ArgumentError, "missing params (api_key)" if params[:api_key].nil?
    @api_key = params[:api_key]
  end
end

require "fileturn/exceptions"
require "fileturn/http_client"
require "fileturn/resources/resource"
require "fileturn/resources/upload"
require "fileturn/resources/notification"
require "fileturn/resources/file"