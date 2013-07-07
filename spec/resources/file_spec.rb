require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::File do

  def retrieve_successful_file
    @sfile ||= FileTurn::File.find(212)
  end

  def retrieve_failed_file
    @ffile ||= FileTurn::File.find(154)
  end

  def retrieve_queued_file
    @qfile ||= FileTurn::File.find(210)
  end

  def user_without_credits
    FileTurn.configure(:api_key => 'vGAMKzyN1pFGCNcCFsPpjjVVZtvim1zop3te2pQU')
  end

  describe '.find' do
    it 'raises exception if unauthorized' do
      FileTurn.configure(:api_key => 'blah')
      expect { FileTurn::File.find(123) }.to raise_error(FileTurn::UnauthorizedException)
    end

    it 'returns the file' do
      file = FileTurn::File.find(212)
      file.id.should == 212
      file.url.should == "http://www.k12.wa.us/rti/implementation/pubdocs/SchoolBlueprint.doc"
      file.convert_to.should == 'pdf'
      file.created_at.should == DateTime.parse('2013-07-07T03:38:20Z')
      file.status == 'processed'
      file.download_url == "https://fileturn.s3.amazonaws.com/8_212.pdf?AWSAccessKeyId=AKIAIKXW3ZZ5WNURNYMA&Expires=1373259946&Signature=K60jm8kkSkXYjoEi8eVVr%2Bh1bBY%3D"
    end

    it 'returns notifications for the file' do
      file = FileTurn::File.find(212)
      file.notifications.count.should == 1
      file.notifications.first.id == 184
    end
  end

  describe '.all' do
    it 'fetches all the files' do
      obj = FileTurn::File.all
      obj.files.count.should == 20
      obj.current_page == 1
      obj.per_page == 20
      obj.total_pages == 3 
    end

    it 'fetches all the notifications' do
      obj = FileTurn::File.all
      file = obj.files.first
      file.notifications.count.should == 1
    end
  end

  describe '.convert' do
    it 'with no parameters' do
      expected = { 'url' => ["can't be blank"], 'convert_to' => ["can't be blank"] }
      response = FileTurn::File.convert({})
      response.errors.should == expected
    end

    it 'properly converts a file response' do
      file = FileTurn::File.convert(:url => 'http://test.com', :convert_to => :pdf)
      file.queued?.should == true
      file.url.should == 'http://test.com'
      file.notifications.count.should == 0
    end
  end

  describe 'upload' do
    it 'converts an uploaded file' do
      file = FileTurn::File.convert(:file => File.open('README.md'), :convert_to => :pdf)
      file.queued?.should == true
    end

    it 'converts and uploads a doc file' do
      file = FileTurn::File.convert(:file => File.open('./spec/data/testfile.docx'), :convert_to => :pdf)
      file.queued?.should == true
    end

    it 'doesnt upload a file if there are not enough credits' do
      user_without_credits
      file = FileTurn::File.convert(:file => File.open('./spec/data/testfile.docx'), :convert_to => :pdf)
      file.queued?.should == nil
      file.errors.should == {'credits'=>['need more credits to convert files']}
    
      FileTurn::Upload.all.uploads.count.should == 0
    end
  end

  it '#success?' do
    expected_results = { 
      retrieve_successful_file => true,
      retrieve_failed_file => false,
      retrieve_queued_file => false
    }

    expected_results.each { |f, r| f.success?.should == r }
  end

  it '#failed?' do
    expected_results = { 
      retrieve_successful_file => false,
      retrieve_failed_file => true,
      retrieve_queued_file => false
    }

    expected_results.each { |f, r| f.failed?.should == r }
  end

  it '#queued?' do
    expected_results = { 
      retrieve_successful_file => false,
      retrieve_failed_file => false,
      retrieve_queued_file => true
    }

    expected_results.each { |f, r| f.queued?.should == r }
  end

  it '#reload returns expected results' do
    retrieve_successful_file.should_receive(:parse_json_params)
    old_result = retrieve_successful_file.params
    retrieve_successful_file.reload.params.should == old_result
  end
  
  it '#time_taken returns expected results' do
    expected_results = { 
      retrieve_successful_file => 105.926075,
      retrieve_failed_file => nil,
      retrieve_queued_file => nil
    }

    expected_results.each { |f, r| f.time_taken.should == r }
  end

end