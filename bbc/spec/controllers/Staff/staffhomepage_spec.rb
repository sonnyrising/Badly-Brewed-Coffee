require_relative '../../spec_helper'

RSpec.describe 'GET /staff/homepage' do
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
        get '/staff/homepage'
        expect(last_response.status).to eq(200)
      end

      it 'renders the homepage view' do
        get '/staff/homepage'
        expect(last_response.body).to include('homepage')
      end
    end
  end
end

