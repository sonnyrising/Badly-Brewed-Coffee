require_relative '../spec_helper'

RSpec.describe 'GET /login' do
  context 'when visiting the login page' do
    it 'returns 200' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it 'renders the login form' do
      get '/login'
      expect(last_response.body).to include('login')
    end

    it 'clears the session' do
      get '/login'
      expect(last_request.session).to be_empty
    end
  end
end

RSpec.describe 'POST /login' do
  let(:valid_params) do
    {
      'uname' => 'TestUser',
      'pword' => 'Password1!'
    }
  end

  describe 'successful login' do
    context 'when credentials are correct and account is active' do
      it 'redirects to the user homepage' do
        post '/login', valid_params
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/homepage')
      end

      it 'sets the userId session variable' do
        post '/login', valid_params
        expect(last_request.session[:userId]).not_to be_nil
      end

      it 'sets the uname session variable' do
        post '/login', valid_params
        expect(last_request.session[:uname]).to eq('TestUser')
      end
    end
  end
end