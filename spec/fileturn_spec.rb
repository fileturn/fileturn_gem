require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileTurn do

  describe '#configure' do
    it 'sets up api key' do
      FileTurn.configure(:api_key => "123")
      FileTurn.api_key.should == "123"
    end

    it 'raises exception if not api key is passed' do
      expect { FileTurn.configure({}) }.to raise_error
    end
  end

end