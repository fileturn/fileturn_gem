module FileTurn
  class FileTurnError < Exception; end
  class NotFoundError < FileTurnError; end;
  class UnauthorizedError < FileTurnError; end;
  class UnknownError < FileTurnError; end;

  class BadRequestError < FileTurnError
    attr_reader :errors

    def initialize(resp)
      @errors = resp['errors']
    end
  end
end
