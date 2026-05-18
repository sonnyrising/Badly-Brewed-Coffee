require_relative '../../spec_helper'

RSpec.describe 'Checkout / Thank You Page Logic' do
  let(:staff_session) { { 'rack.session' => { userId: 100, uname: 'customer' } } }

  before(:each) do
    spec_before
  end

    context 'checkout process' do
    it 'creates a transaction and increases coffee loyalty points' do
      post '/thankyoupage', {
        customerId: 100,
        totalcost: 20.00,
        address: 'Address',
        beans: 0
      }, staff_session

      expect(last_response.status).to eq(200)

      transaction = Transactions.last
      expect(transaction.UserId).to eq(100)
      expect(transaction.TotalCost).to eq(20.00)
      expect(transaction.Status).to eq('Pending')

      expect(Users[1].LoyaltyPoints).not_to be_nil
    end

    it 'creates transaction where beans is true' do
      post '/thankyoupage', {
        customerId: 100,
        totalcost: 30.00,
        address: 'Address',
        beans: 1,
        TransactionId: nil
      }, staff_session

      expect(last_response.status).to eq(200)

      transaction = Transactions.last
      expect(transaction.UserId).to eq(100)
      expect(transaction.TotalCost).to eq(30.00)

      expect(Users[1].LoyaltyPoints).not_to be_nil
    end
  end
end
