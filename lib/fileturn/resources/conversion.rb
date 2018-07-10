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
        conn.post("conversions.json", params, 200) do |params|
          FileTurn::Conversion.new(params)
        end
      end

    private

      # def upload_file(file, params)
      #   evaluate_file_size = FileTurn::Upload.send(:evaluate_file_size, file)
      #   return evaluate_file_size unless evaluate_file_size.nil?

      #   signed_params = FileTurn::Upload.send(:signed_upload_url, file)
      #   return signed_params if signed_params.errors

      #   faraday = Faraday.new(:url => signed_params.url) do |conn| 
      #     conn.request :multipart
      #     conn.adapter :net_http
      #   end

      #   response = faraday.post '/', {
      #     :policy => signed_params.policy,
      #     :signature => signed_params.signature,
      #     'AWSAccessKeyId' => signed_params.aws_access_key_id,
      #     :key => signed_params.key,
      #     :file => Faraday::UploadIO.new(file.path, '')
      #   }

      #   if response.status == 204
      #     params[:file] = params['file'] = nil
      #     params['url'] = "#{signed_params.url}/#{signed_params.key}"
      #     params['file_type'] = signed_params.file_type
      #     params['upload_id'] = signed_params.id
      #     convert(params)
      #   end
      # end

    end

  end
end