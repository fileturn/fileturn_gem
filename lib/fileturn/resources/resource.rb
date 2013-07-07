module FileTurn
  class Resource
    
    # class
    class << self
      def conn
        FileTurn::HttpClient
      end
    end

    # instance

  end
end