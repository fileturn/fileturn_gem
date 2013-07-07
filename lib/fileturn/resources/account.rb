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

      def load_only_if_not_loaded
        load if @account.nil? || @account.id.nil?
        self
      end

      def id
        @account.id
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

      def max_file_size_in_bytes
        @account.max_file_size_in_bytes
      end
    end

  end
end