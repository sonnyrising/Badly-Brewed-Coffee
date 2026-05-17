require_relative '../../spec_helper'

RSpec.describe 'GET /user/homepage' do
  before do
    # Create and login a test user
    post '/register', {
      'uname' => 'test',
      'email' => 'test@mail.com',
      'pword' => 'Password123!',
      'confirmpword' => 'Password123!'
    }
  end

  #Logged in/created an account successfully

  describe 'successful homepage access' do
    context 'when the user is logged in' do
      it 'returns 200' do
        get '/user/homepage'
        expect(last_response.status).to eq(200)
      end

      it 'renders the homepage view' do
        get '/user/homepage'
        expect(last_response.body).to include('homepage')
      end
    end
  end

  #Checking transaction for user

  describe 'homepage order information' do
    context 'when the user has no previous orders' do
      it 'loads successfully with no recent items' do
        get '/user/homepage'

        expect(last_response.status).to eq(200)
      end
    end

  context 'when the user has previous orders' do
      before do
        user_id = last_request.session[:userId]

        transaction_id = Transactions.insert(
          UserId: user_id,
          TotalCost: 12,
          Address: '21 Test avenue',
          TransactionDate: 15052026,
          Status: 'Pending',
          RefundRequested: false
        )

        product_id = Products.first.ProductId

        Basket.insert(
          UserId: user_id,
          ProductId: product_id,
          Quantity: 2,
          TransactionId: transaction_id
        )
      end

      it 'returns 200 successfully' do
        get '/user/homepage'
        expect(last_response.status).to eq(200)
      end

      it 'loads recent order items' do
        get '/user/homepage'

        expect(last_response.body).not_to be_nil
      end
    end
  end
end

