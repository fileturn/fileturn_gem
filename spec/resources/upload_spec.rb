require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::Upload do
  
  describe '.all' do
    it 'retrives all the uploaded files' do
      obj = FileTurn::Upload.all
      obj.uploads.count.should == 20
      obj.current_page.should == 1
      obj.per_page.should == 20
      obj.total_pages.should >= 4
    end
  end

  describe '.find' do
    it 'fetches a single uploaded file' do
      upload = FileTurn::Upload.find(19)
      upload.id.should == 19
      upload.policy.should_not be_empty
      upload.signature.should_not be_empty
      upload.aws_access_key_id.should_not be_empty
      upload.key.should_not be_empty
      upload.url.should_not be_empty
    end

    it 'reload fetches the info again' do
      upload = FileTurn::Upload.find(19)
      old_params = upload.params
      upload.should_receive(:parse_json_params)

      upload.reload.params.should == old_params
    end
  end

end