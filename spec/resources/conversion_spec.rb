require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::Conversion do

  let(:successful_conversion_id) { 'b120b954-82b2-41c6-bef2-c83b3462463b' }

  describe '.find' do
    it 'raises exception when not authorized' do
      VCR.use_cassette('conversion_not_authorized') do
        FileTurn.configure(api_token: '123')
        expect { FileTurn::Conversion.find(successful_conversion_id) }.to raise_error(FileTurn::NotFoundError)
      end
    end

    it 'raises exception when not found' do
      VCR.use_cassette('conversion_not_found') do
        expect { FileTurn::Conversion.find(123) }.to raise_error(FileTurn::NotFoundError)
      end
    end

    it 'returns the conversion' do
      VCR.use_cassette('conversion_success') do
        conversion = FileTurn::Conversion.find(successful_conversion_id)
        expect(conversion.id).to eq(successful_conversion_id)
        expect(conversion.type).to eq('WordToPdf')
      end
    end

    it 'returns notification responses for conversion' do
      VCR.use_cassette('conversion_success') do
        conversion = FileTurn::Conversion.find(successful_conversion_id)
        expect(conversion.notification_responses.count).to be(1)
      end
    end
  end

  describe '.all' do
    it 'raises exception when not authorized' do
      VCR.use_cassette('conversion_all_not_authorized') do
        FileTurn.configure(api_token: '123')
        expect { FileTurn::Conversion.all }.to raise_error(FileTurn::UnauthorizedError)
      end
    end

    it 'fetches all the conversions' do
      VCR.use_cassette('conversions_all') do
        obj = FileTurn::Conversion.all

        expect(obj.current_page).to be(1)
        expect(obj.per_page).to be(20)
        expect(obj.total_pages).to_not be_nil
        expect(obj.total_conversions).to_not be_nil

        expect(obj.conversions).to_not be(0)
      end
    end

    it 'fetches 5 conversions from second page' do
      VCR.use_cassette('conversions_all_second') do
        obj = FileTurn::Conversion.all(page: 2, per: 5)

        expect(obj.current_page).to be(2)
        expect(obj.per_page).to be(5)
        expect(obj.total_pages).to_not be_nil
        expect(obj.total_conversions).to_not be_nil

        expect(obj.conversions).to_not be(0)

        expect(obj.conversions.first.class).to be(FileTurn::Conversion)
        expect(obj.conversions.first.reload!.temporary_download_urls.count).to be(1)
      end
    end
  end

  describe '.process!' do
    it 'with no parameters' do
      VCR.use_cassette('conversion_process_no_params') do
        expect { FileTurn::Conversion.process!({}) }.to raise_error(FileTurn::BadRequestError)

        begin
          FileTurn::Conversion.process!({})
        rescue FileTurn::BadRequestError => ex
          expect(ex.errors).to include("Type can't be blank")
          expect(ex.errors).to include("Source files can't be blank")
        end
      end
    end

    it 'is created and successful' do
      VCR.use_cassette('conversion_process_created') do
        conv = FileTurn::Conversion.process!(url: "http://iiswc.org/iiswc2013/sample.doc", type: "WordToPdf")
        expect(conv.created?).to be(true)

        VCR.use_cassette('conversion_process_success') do
          conv = FileTurn::Conversion.find(conv.id)
          expect(conv.created?).to be(false)
          expect(conv.completed?).to be(true)
        end
      end
    end

    it 'allows uploading file' do
      VCR.use_cassette('conversion_with_file_created') do
        conv = FileTurn::Conversion.process!(file: File.open('./spec/data/testfile.docx'), type: "WordToPdf")
        expect(conv.created?).to be(true)
        expect(conv.source_files.first).to include('amazonaws.com')

        VCR.use_cassette('conversion_with_file_success') do
          conv = FileTurn::Conversion.find(conv.id)
          expect(conv.created?).to be(false)
          expect(conv.completed?).to be(true)
        end
      end
    end
  end

  describe 'reload!' do
    it 'fetches from server' do
      VCR.use_cassette('reload!') do
        conv = FileTurn::Conversion.process!(url: "http://iiswc.org/iiswc2013/sample.doc", type: "WordToPdf")
        expect(conv.created?).to be(true)

        VCR.use_cassette('reload_done') do
          conv.reload!
          expect(conv.created?).to be(false)
          expect(conv.completed?).to be(true)
        end
      end
    end
  end

  # describe 'upload' do
  #   it 'converts an uploaded file' do
  #     VCR.use_cassette('file_upload_queued') do
  #       file = FileTurn::File.convert(:file => File.open('README.md'), :convert_to => :pdf)
  #       file.queued?.should == true
  #     end
  #   end

  #   it 'converts and uploads a doc file' do
  #     VCR.use_cassette('file_upload_doc_queued') do
  #       file = FileTurn::File.convert(:file => File.open('./spec/data/testfile.docx'), :convert_to => :pdf)
  #       file.queued?.should == true
  #     end
  #   end

  #   it 'doesnt upload a file if there are not enough credits' do
  #     VCR.use_cassette('file_upload_not_enough_credits') do
  #       user_without_credits
  #       file = FileTurn::File.convert(:file => File.open('./spec/data/testfile.docx'), :convert_to => :pdf)
  #       file.queued?.should == nil
  #       file.errors.should == {'credits'=>['need more credits to convert files']}
      
  #       FileTurn::Upload.all.uploads.count.should == 0
  #     end
  #   end

  #   it 'doesnt upload since file is too big' do
  #     user_without_credits
  #     FileTurn::Account.should_receive(:max_file_size_in_bytes).and_return(0)
  #     file = FileTurn::File.convert(:file => File.open('./spec/data/testfile.docx'), :convert_to => :pdf)
  #     file.queued?.should == nil
  #     file.errors.should == {'file_size'=>['is too big']}

  #     VCR.use_cassette('file_doesnt_upload_since_too_big') do
  #       FileTurn::Upload.all.uploads.count.should == 0
  #     end
  #   end
  # end

  # it '#success?' do
  #   VCR.use_cassette('file_success?') do
  #     expected_results = { 
  #       retrieve_successful_file => true,
  #       retrieve_failed_file => false,
  #       retrieve_queued_file => false
  #     }

  #     expected_results.each { |f, r| f.success?.should == r }
  #   end
  # end

  # it '#failed?' do
  #   VCR.use_cassette('file_failed?') do
  #     expected_results = { 
  #       retrieve_successful_file => false,
  #       retrieve_failed_file => true,
  #       retrieve_queued_file => false
  #     }

  #     expected_results.each { |f, r| f.failed?.should == r }
  #   end
  # end

  # it '#queued?' do
  #   VCR.use_cassette('file_queued?') do
  #     expected_results = { 
  #       retrieve_successful_file => false,
  #       retrieve_failed_file => false,
  #       retrieve_queued_file => true
  #     }

  #     expected_results.each { |f, r| f.queued?.should == r }
  #   end
  # end

  # it '#reload returns expected results' do
  #   VCR.use_cassette('file_reload') do
  #     retrieve_successful_file.should_receive(:parse_json_params)
  #     old_result = retrieve_successful_file.params
  #     retrieve_successful_file.reload.params.should == old_result
  #   end
  # end
  
  # it '#time_taken returns expected results' do
  #   VCR.use_cassette('file_time_taken') do
  #     expected_results = { 
  #       retrieve_successful_file => 105.926075,
  #       retrieve_failed_file => nil,
  #       retrieve_queued_file => nil
  #     }

  #     expected_results.each { |f, r| f.time_taken.should == r }
  #   end
  # end

end