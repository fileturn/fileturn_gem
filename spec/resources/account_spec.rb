require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileTurn::Account do
  it 'retrieves account information' do
    VCR.use_cassette('account_info') do
      account = FileTurn::Account.load

      expect(account.id).to_not be_nil
      expect(account.email).to_not be_nil
      expect(account.plan.name).to_not be_nil
      expect(account.subscription.billing_cycle_started).to_not be_nil
      expect(account.subscription.billing_cycle_ends).to_not be_nil
      expect(account.subscription.stats.conversions_left).to_not be_nil
    end
  end
end
