module FileTurn
  class File < Resource
   
    # class
    class << self
      
      def find(id, &block)
        conn.get("/files/#{id}.json", {}, 200) do |params|
          block ? block.call(params) : File.new(params)
        end
      end

      def all
        conn.get("files.json", {}, 200) do |params|
          files = Array(params['files']).map { |p| File.new(p) }
          OpenStruct.new(
            :files => files, 
            :total_files => params['total_files'],
            :current_page => params['current_page'],
            :per_page => params['per_page'],
            :total_pages => params['total_pages']
          )
        end
      end

      def convert(params)
        file = params['file'] || params[:file]
        return upload_file(file, params) unless file.nil?

        conn.post("files.json", params, 201) do |params|
          File.new(params)
        end
      end

    private

      def upload_file(file, params)
        signed_params = signed_upload_url(file)
        return signed_params unless (signed_params.keys.include?("policy") rescue false)
        
        faraday = Faraday.new(:url => signed_params['url']) do |conn| 
          conn.request :multipart
          conn.adapter :net_http
        end

        response = faraday.post '/', {
          :policy => signed_params['policy'],
          :signature => signed_params['signature'],
          'AWSAccessKeyId' => signed_params['aws_access_key_id'],
          :key => signed_params['key'],
          :file => Faraday::UploadIO.new(file.path, '')
        }

        if response.status == 204
          params[:file] = params['file'] = nil
          params['url'] = "#{signed_params['url']}/#{signed_params['key']}"
          params['file_type'] = file.class.extname(file.path).gsub('.', '')
          params['upload_id'] = signed_params['id']
          convert(params)
        end
      end

      def signed_upload_url(file)
        file_type = file.class.extname(file.path).gsub('.', '')
        file_type = 'unknown' if file_type == ''
        file_size = file.class.size(file.path)

        conn.post('files/upload.json', { content_type: file_type, content_length: file_size }, 201) do |params|
          params
        end
      end

    end

    #vars
    attr_accessor :id, :url, :convert_to, :created_at, :status,
                  :download_url, :notifications, :params

    # instance
    def initialize(params={})
      parse_json_params(params)
    end

    def success?
      status == 'processed'
    end

    def failed?
      status == 'failed'
    end

    def queued?
      status == 'queued'
    end

    def reload
      File.find(id) { |params| parse_json_params(params) }
      self
    end

    def time_taken
      notifications.last && notifications.last.time_taken
    end

private

    def parse_json_params(params)
      @params = params
      @id = params['id']
      @url = params['url']
      @convert_to = params['convert_to']
      @created_at = DateTime.parse(params['created_at'])
      @status = params['status']
      @download_url = params['download_url']
      @notifications = Array(params['notifications']).map { |p| Notification.new(p) }
    end

  end
end