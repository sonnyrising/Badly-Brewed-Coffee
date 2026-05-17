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
      'uname' => 'User123!',
      'pword' => 'User123!'
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
        expect(last_request.session[:uname]).to eq('test')
      end
    end
  end

  describe 'blank field validation' do
    context 'when username is blank' do
      it 'returns 200 and shows username error' do
        post '/login', valid_params.merge('uname' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter a username')
      end
    end

    context 'when password is blank' do
      it 'returns 200 and shows password error' do
        post '/login', valid_params.merge('pword' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter a password')
      end
    end

    context 'when both username and password are blank' do
      it 'shows both validation errors' do
        post '/login', {
          'uname' => '',
          'pword' => ''
        }

        expect(last_response.body).to include('Please enter a username')
        expect(last_response.body).to include('Please enter a password')
      end
    end
  end


end
