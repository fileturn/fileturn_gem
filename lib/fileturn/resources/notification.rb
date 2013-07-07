module FileTurn
  class Notification < Resource
    attr_reader :id, :details, :parsed_time, :status, :time_taken,
                :file_id, :params

    def initialize(params)
      @params = params
      @id = params['id']
      @details = params['details']
      @parsed_time = DateTime.parse(params['parsed_time']) if params['parsed_time']
      @status = params['status']
      @time_taken = params['time_taken'].to_f if params['time_taken']
      @file_id = params['doc_id']
    end
  end
end