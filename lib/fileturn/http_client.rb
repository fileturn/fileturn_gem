require 'faraday'
require 'json'
require 'ostruct'

module FileTurn
  class HttpClient

    def self.conn
      @conn ||= Faraday.new(:url => 'http://localhost:3000/')
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
      params['token'] = FileTurn.api_key
      params
    end

    def self.handle_error(resp)
      case resp.status
      when 401
        raise FileTurn::UnauthorizedException.new(resp)
      when 500
        raise FileTurn::InternalServerException.new(resp)
      when 422
        OpenStruct.new(JSON.parse(resp.body))
      else
        nil
      end
    end
  end
end