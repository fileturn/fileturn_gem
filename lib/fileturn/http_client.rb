require 'faraday'
require 'json'
require 'ostruct'

module FileTurn
  class HttpClient

    def self.conn
      @conn ||= Faraday.new(:url => 'https://fileturn.net/')
    end

    def self.get(url, params, status_codes, &block)
      make_call(:get, url, params, status_codes, &block)
    end

    def self.post(url, params, status_codes, &block)
      make_call(:post , url, params, status_codes, &block)
    end


    def self.make_call(type, url, params, status_codes, &block)
      params = setup_params(params)
      resp = conn.send(type, "api/#{url}") { |req| req.params = params }
      if Array(status_codes).include?(resp.status)
        block.call(JSON.parse(resp.body))
      else
        handle_error(resp)
      end
    end

    def self.setup_params(params)
      params['api_token'] = FileTurn.api_token
      params
    end

    def self.handle_error(resp)
      case resp.status
      when 200..399
        nil
      when 400
        raise FileTurn::BadRequestError.new(JSON.parse(resp.body))
      when 401
        raise FileTurn::UnauthorizedError.new(resp)
      when 404
        raise FileTurn::NotFoundError.new(resp)
      else
        raise FileTurn::UnknownError.new(resp)
      end
    end
  end
end