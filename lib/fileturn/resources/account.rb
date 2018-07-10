module FileTurn
  class Account < Resource

    def initialize(params)
      @params = RecursiveOpenStruct.new(params, recurse_over_arrays: true)
    end

    def method_missing(m, *args, &block)
      @params.send(m)
      self
    end
   
    class << self
      def load
        conn.get("/users.json", {}, 200) do |params|
          FileTurn::Account.new(params)
        end
      end
    end

  end
end
