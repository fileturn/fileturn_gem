require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileTurn do

  describe '#configure' do
    it 'sets up api token' do
      FileTurn.configure(api_token: "123")
      expect(FileTurn.api_token).to eq("123")
    end

    it 'raises exception if not api token is passed' do
      expect { FileTurn.configure({}) }.to raise_error(ArgumentError)
    end
  end

end