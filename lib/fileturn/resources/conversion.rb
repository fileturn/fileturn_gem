module FileTurn
  class Conversion < Resource
    attr_reader :params

    def initialize(params)
      @params = RecursiveOpenStruct.new(params, recurse_over_arrays: true)
    end

    def method_missing(m, *args, &block)
      @params.send(m)
    end

    def reload!
      @params = FileTurn::Conversion.find(id).params
      self
    end

    ['created', 'processing', 'failed', 'completed'].each do |s|
      define_method("#{s}?") do
        s == status
      end
    end

    # class
    class << self
      
      def find(id, &block)
        conn.get("/conversions/#{id}.json", {}, 200) do |params|
          FileTurn::Conversion.new(params)
        end
      end

      def all(per: 20, page: 1)
        conn.get("conversions.json", { per: per, page: page }, 200) do |params|
          params['conversions'].map! { |conv| FileTurn::Conversion.new(conv) }
          RecursiveOpenStruct.new(params, recurse_over_arrays: true)
        end
      end

      def process!(params)
        if params[:file]
          params[:url] ||= Upload.process!(params[:file]).download_url
          params[:file] = nil
        end

        conn.post("conversions.json", params, 200) do |params|
          FileTurn::Conversion.new(params)
        end
      end

    end

  end
end