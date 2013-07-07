module FileTurn
  class Resource
    
    # class
    class << self
      def conn
        FileTurn::HttpClient
      end
    end

    # instance
    def errors
      false
    end

  end
end