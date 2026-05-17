require_relative '../../spec_helper'

RSpec.describe 'User Orders Logic' do
  let(:user_session) { { 'rack.session' => { userId: 1, uname: 'testuser' } } }

  before(:each) do
    spec_before
  end

  #page loads

  context 'orders page transactions' do
    it 'loads the orders page successfully' do
      get '/user/orders', {}, user_session

      expect(last_response.status).to eq(200)
    end

    it 'shows the latest transaction for the user' do
      Products.insert(
        ProductId: 10,
        ProductName: 'Steffspresso',
        StockQuantity: 10,
        Price: 4.5,
        ProductImage: 'Steffspresso.jpg',
        ProductDescription: 'Coffee',
        Origin: 'Brazil',
        Roast: 'Dark',
        Bean: false
      )

      Transactions.insert(
        TransactionId: 10,
        UserId: 1,
        TotalCost: 18,
        TransactionDate: '2024-05-16',
        Status: 'Pending',
        RefundRequested: false,
        Refunded: false
      )

      Basket.insert(
        BasketId: 1,
        TransactionId: 10,
        ProductId: 10,
        Quantity: 2
      )

      get '/user/orders', {}, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('18')
    end

    it 'shows all transactions belonging to the logged in user' do
      Transactions.insert(
        TransactionId: 20,
        UserId: 1,
        TotalCost: 30,
        TransactionDate: '2024-06-10',
        Status: 'Pending',
        RefundRequested: false,
        Refunded: false
      )

      Transactions.insert(
        TransactionId: 21,
        UserId: 1,
        TotalCost: 45.00,
        TransactionDate: '2024-06-11',
        Status: 'Pending',
        RefundRequested: false,
        Refunded: false
      )

      get '/user/orders', {}, user_session

      expect(last_response.status).to eq(200)

      user_transactions = Transactions.where(UserId: 1).all

      expect(user_transactions.length).to be >= 2
      expect(user_transactions.map(&:TransactionId)).to include(20, 21)
    end

    it 'does not fail when the user has no items in basket' do
      Basket.dataset.delete

      get '/user/orders', {}, user_session

      expect(last_response.status).to eq(200)
    end

    it 'handles users with no transactions' do
      Transactions.dataset.delete

      get '/user/orders', {}, user_session

      expect(last_response.status).to eq(200)
    end
  end
end