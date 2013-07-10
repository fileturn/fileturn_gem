module FileTurn
  class HttpClient
    def self.conn
      @conn ||= Faraday.new(:url => 'http://localhost:3000/')
    end
  end
end