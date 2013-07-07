require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::Account do
  it 'retrieves account information' do
    VCR.use_cassette('account_info') do
      FileTurn::Account.load
      FileTurn::Account.credits.should_not be_nil
      FileTurn::Account.time_zone.should_not be_nil
      FileTurn::Account.notification_url.should_not be_nil
      FileTurn::Account.max_file_size_in_bytes.should == 1048576
      FileTurn::Account.created_at.class.should == DateTime
    end
  end

  it 'makes the call only once' do
    VCR.use_cassette('account_info_once') do
      FileTurn::Account.conn.should_receive(:get).once
      FileTurn::Account.load
      FileTurn::Account.credits
    end
  end

  it 'makes the call only twice' do
    VCR.use_cassette('account_info_twice') do
      FileTurn::Account.conn.should_receive(:get).twice
      FileTurn::Account.load
      FileTurn::Account.load
      FileTurn::Account.credits
    end
  end
end