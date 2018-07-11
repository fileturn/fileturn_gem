require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::Upload do
  
  describe '.find' do
    it 'get a single upload' do
      VCR.use_cassette('single_upload') do
        id = 'dec67910-6d22-411a-8c3d-4ae1db69469d'
        upload = FileTurn::Upload.find(id)
        expect(upload.id).to eq(id)
        expect(upload.fields.key).to_not be_nil
        expect(upload.url).to_not be_nil
        expect(upload.download_url).to_not be_nil
      end
    end

    it 'successfully reloads' do
      VCR.use_cassette('single_upload') do
        id = 'dec67910-6d22-411a-8c3d-4ae1db69469d'
        upload = FileTurn::Upload.find(id)
        expect(upload.reload!.id).to eq(id)
      end
    end
  end

  describe '.process!' do
    it 'saves upload' do
      VCR.use_cassette('single_create') do
        upload = FileTurn::Upload.process!(File.open('./spec/data/testfile.docx'))
        expect(upload.download_url).to_not be_nil
      end
    end
  end

end