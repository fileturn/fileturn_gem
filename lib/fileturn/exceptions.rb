module FileTurn
  
  class FileTurnException < Exception
    attr_reader :resp
    def initialize(resp)
      @resp = resp
    end

    def to_s
      resp
    end
  end

  class UnauthorizedException < FileTurnException; end;
  class InternalServerException < FileTurnException; end;

  class UnprocessableEntityException < FileTurnException
    attr_reader :parsed_response
    
    def initialize(resp)
      super(resp)
      @parsed_response = OpenStruct.new(JSON.parse(resp.body))
    end

    def to_s
      @parsed_response.to_s
    end
  end

end