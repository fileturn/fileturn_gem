module FileTurn
  class HttpClient
    def self.conn
      @conn ||= Faraday.new(:url => 'http://localhost:5000/')
    end
  end
end