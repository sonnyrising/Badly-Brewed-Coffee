require_relative '../../spec_helper'

RSpec.describe 'Checkout / Thank You Page Logic' do
  let(:user_session) { { 'rack.session' => { userId: 1, uname: 'testuser' } } }

  before(:each) do
    spec_before
  end

  context 'checkout process (coffee order)' do
    it 'creates a transaction and increases coffee loyalty points' do
      post '/thankyoupage', {
        userId: 1,
        totalcost: 20.00,
        address: 'Test Address',
        beans: 0
      }, user_session

      expect(last_response.status).to eq(200)

      transaction = Transactions.last
      expect(transaction.UserId).to eq(1)
      expect(transaction.TotalCost).to eq(20.00)
      expect(transaction.Status).to eq('Pending')

      expect(Users[1].LoyaltyPoints).not_to be_nil
    end

    it 'creates transaction and handles bean purchase flow' do
      post '/thankyoupage', {
        userId: 1,
        totalcost: 30.00,
        address: 'Test Address',
        beans: 1,
        TransactionId: nil
      }, user_session

      expect(last_response.status).to eq(200)

      transaction = Transactions.last
      expect(transaction.UserId).to eq(1)
      expect(transaction.TotalCost).to eq(30.00)

      expect(Users[1].LoyaltyPoints).not_to be_nil
    end
  end

  context 'basket and transaction effects' do
    it 'creates transaction record in database' do
      expect {
        post '/thankyoupage', {
          userId: 1,
          totalcost: 15.00,
          address: 'Test Address',
          beans: 0
        }, user_session
      }.to change { Transactions.count }.by(1)
    end
  end
end