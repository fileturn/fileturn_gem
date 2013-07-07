module FileTurn
  class Account < Resource
   
    class << self
      @account = OpenStruct.new()

      def load
        conn.get("/users.json", {}, 200) do |params|
          params['created_at'] = DateTime.parse(params['created_at'])
          @account = OpenStruct.new(params)
          self
        end
      end

      def credits
        @account.credits
      end

      def created_at
        @account.created_at
      end

      def notification_url
        @account.notification_url
      end

      def time_zone
        @account.time_zone
      end
    end

  end
end