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

  #Successful login

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
        expect(last_request.session[:uname]).to eq('User123!')
      end
    end
  end

  #Missing fields

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

  #Invalid credentials

  describe 'invalid credentials' do
    context 'when username does not exist' do
      it 'returns 200 and shows matching error' do
        post '/login', {
          'uname' => 'incorrectUsername',
          'pword' => 'password'
        }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Username or password are incorrect')
      end
    end

    context 'when password is incorrect' do
      it 'returns 200 and shows matching error' do
        post '/login', {
          'uname' => 'User123!',
          'pword' => 'incorrectPassword'
        }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Username or password are incorrect')
      end
    end
  end

  #Suspended account

  describe 'suspended account' do
    context 'when the user account is suspended' do
      it 'returns 200 and shows suspended account message' do
        post '/login', {
          'uname' => 'Suspended',
          'pword' => 'Suspended123!'
        }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include(
          'Account suspended due to inactivity for more than 6 months. Please contact support.'
        )
      end
    end
  end

  #Empty form

  describe 'empty form submission' do
    context 'when no params are submitted' do
      it 'returns 200' do
        post '/login', {}
        expect(last_response.status).to eq(200)
      end

      it 'shows both validation errors' do
        post '/login', {}

        expect(last_response.body).to include('Please enter a username')
        expect(last_response.body).to include('Please enter a password')
      end
    end
  end
end

#Logging in as a guest

RSpec.describe 'POST /guestlogin' do
  context 'when logging in as a guest' do
    it 'redirects to /user/homepage' do
      post '/guestlogin'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/user/homepage')
    end

    it 'sets the guest session to 1' do
      post '/guestlogin'
      expect(last_request.session[:userId]).to eq(1)
    end

    it 'sets the guest session username' do
      post '/guestlogin'
      expect(last_request.session[:uname]).to eq('Guest')
    end
  end
end

RSpec.describe 'GET /logout' do
  context 'when logging out' do
    it 'clears the session' do
      get '/logout'
      expect(last_request.session).to be_empty
    end

    it 'redirects to /login' do
      get '/logout'
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/login')
    end
  end
end
