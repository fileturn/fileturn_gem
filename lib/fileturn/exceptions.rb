module FileTurn
  
  class FileTurnException < Exception
    attr_reader :resp
    def initialize(resp)
      @resp = resp
    end
  end

  class UnauthorizedException < FileTurnException; end;
  class InternalServerException < FileTurnException; end;
end