module FileTurn
  class Upload < Resource
   
    # class
    class << self
      
      def find(id, &block)
        conn.get("/uploads/#{id}.json", {}, 200) do |params|
          block ? block.call(params) : Upload.new(params)
        end
      end

      def all
        conn.get("uploads.json", {}, 200) do |params|
          uploads = Array(params['uploads']).map { |p| Upload.new(p) }
          OpenStruct.new(
            :uploads => uploads, 
            :total_uploads => params['total_uploads'],
            :current_page => params['current_page'],
            :per_page => params['per_page'],
            :total_pages => params['total_pages']
          )
        end
      end

    private

      def signed_upload_url(file)
        file_type = file.class.extname(file.path).gsub('.', '')
        file_type = 'unknown' if file_type == ''
        file_size = file.class.size(file.path)

        conn.post('files/upload.json', { content_type: file_type, content_length: file_size }, 201) do |params|
          params['file_type'] = file_type
          params['file_size'] = file_size
          OpenStruct.new(params)
        end
      end

      def evaluate_file_size(file)
        max_size = Account.load_only_if_not_loaded.max_file_size_in_bytes
        if file.size > max_size
          OpenStruct.new(:errors => {"file_size"=>["is too big"]})
        end
      end

    end

    #vars
    attr_accessor :id, :url, :policy, :signature, :aws_access_key_id, :key,
                  :params

    # instance
    def initialize(params={})
      parse_json_params(params)
    end

    def reload
      Upload.find(id) { |params| parse_json_params(params) }
      self
    end

private

    def parse_json_params(params)
      @params = params
      @id = params['id']
      @url = params['url']
      @policy = params['policy']
      @signature = params['signature']
      @aws_access_key_id = params['aws_access_key_id']
      @key = params['key']
      @url = params['url']
    end

  end
end