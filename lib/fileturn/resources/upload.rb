module FileTurn
  class Upload < Resource

    # class
    class << self
      def find(id, &block)
        conn.get("/uploads/#{id}.json", {}, 200) do |params|
          FileTurn::Upload.new(params)
        end
      end

      def process!(file)
        conn.post('/uploads.json', { file_name: File.basename(file.path) }, 200) do |params|
          upload = FileTurn::Upload.new(params)
          upload.upload_file!(file)
          upload.reload!
        end
      end
    end

    attr_accessor :params

    def initialize(params)
      @params = RecursiveOpenStruct.new(params, recurse_over_arrays: true)
    end

    def method_missing(m, *args, &block)
      @params.send(m)
    end

    def reload!
      @params = FileTurn::Upload.find(id).params
      self
    end

    def upload_file!(file)
      faraday = Faraday.new(:url => url) do |conn|
        conn.request :multipart
        conn.adapter :net_http
      end

      response = faraday.post '/', fields.to_h.merge(file: Faraday::UploadIO.new(file.path, ''))

      if response.status != 204
        raise FileTurn::BadRequestError.new(response.body)
      end
    end

  end
end
