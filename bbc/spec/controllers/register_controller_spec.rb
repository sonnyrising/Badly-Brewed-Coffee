# frozen_string_literal: true

require_relative '../spec_helper'

# =============================================================================
# Register Controller Tests
# =============================================================================

RSpec.describe 'GET /register' do
  context 'when visiting the registration page' do
    it 'returns 200' do
      get '/register'
      expect(last_response.status).to eq(200)
    end

    it 'renders the registration form' do
      get '/register'
      expect(last_response.body).to include('register')
    end
  end
end


RSpec.describe 'POST /register' do
  let(:valid_params) do
    {
      'uname' => 'NewUser',
      'email' => 'newuser@example.com',
      'pword' => 'Password1!',
      'confirmpword' => 'Password1!'
    }
  end

  # ---------------------------------------------------------------------------
  # Successful registration
  # ---------------------------------------------------------------------------

  describe 'successful registration' do
    context 'when all fields are valid and username is not taken' do
      it 'redirects to /user/homepage' do
        post '/register', valid_params
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/user/homepage')
      end

      it 'does not render any error messages' do
        post '/register', valid_params
        follow_redirect!
        expect(last_response.body).not_to include('Please correct the errors below')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Blank / missing field validation
  # ---------------------------------------------------------------------------

  describe 'blank field validation' do
    context 'when username is blank' do
      it 'returns 200 and shows username error' do
        post '/register', valid_params.merge('uname' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter a username')
      end

      it 'shows the submission error banner' do
        post '/register', valid_params.merge('uname' => '')
        expect(last_response.body).to include('Please correct the errors below')
      end
    end

    context 'when password is blank' do
      it 'returns 200 and shows password error' do
        post '/register', valid_params.merge('pword' => '', 'confirmpword' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter a password')
      end
    end

    context 'when confirm password is blank' do
      it 'returns 200 and shows confirm password error' do
        post '/register', valid_params.merge('confirmpword' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter your password again')
      end
    end

    context 'when email is blank' do
      it 'returns 200 and shows email error' do
        post '/register', valid_params.merge('email' => '')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Please enter a valid email')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Email validation
  # ---------------------------------------------------------------------------

  describe 'email validation' do
    context 'when email is not a valid format' do
      it 'shows the email error for a plain string' do
        post '/register', valid_params.merge('email' => 'notanemail')
        expect(last_response.body).to include('Please enter a valid email')
      end

      it 'shows the email error for a missing domain' do
        post '/register', valid_params.merge('email' => 'user@')
        expect(last_response.body).to include('Please enter a valid email')
      end

      it 'shows the email error for a missing @' do
        post '/register', valid_params.merge('email' => 'userexample.com')
        expect(last_response.body).to include('Please enter a valid email')
      end
    end

    context 'when email is valid' do
      it 'does not show an email error' do
        post '/register', valid_params
        # successful registration redirects, so no email error on the page
        expect(last_response.status).to eq(302)
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Password matching
  # ---------------------------------------------------------------------------

  describe 'password matching' do
    context 'when passwords do not match' do
      it 'returns 200 and shows mismatch error' do
        post '/register', valid_params.merge('confirmpword' => 'Different1!')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Passwords dont match')
      end

      it 'shows the submission error banner' do
        post '/register', valid_params.merge('confirmpword' => 'Different1!')
        expect(last_response.body).to include('Please correct the errors below')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Password strength validation
  # ---------------------------------------------------------------------------

  describe 'password strength validation' do
    context 'when password has no uppercase letter' do
      it 'shows the invalid password error' do
        post '/register', valid_params.merge('pword' => 'password1!', 'confirmpword' => 'password1!')
        expect(last_response.body).to include('Password must contain')
      end
    end

    context 'when password has no lowercase letter' do
      it 'shows the invalid password error' do
        post '/register', valid_params.merge('pword' => 'PASSWORD1!', 'confirmpword' => 'PASSWORD1!')
        expect(last_response.body).to include('Password must contain')
      end
    end

    context 'when password has no digit' do
      it 'shows the invalid password error' do
        post '/register', valid_params.merge('pword' => 'Password!', 'confirmpword' => 'Password!')
        expect(last_response.body).to include('Password must contain')
      end
    end

    context 'when password has no special character' do
      it 'shows the invalid password error' do
        post '/register', valid_params.merge('pword' => 'Password1', 'confirmpword' => 'Password1')
        expect(last_response.body).to include('Password must contain')
      end
    end

    context 'when password is fewer than 8 characters' do
      it 'shows the invalid password error' do
        post '/register', valid_params.merge('pword' => 'Pa1!', 'confirmpword' => 'Pa1!')
        expect(last_response.body).to include('Password must contain')
      end
    end

    context 'when password meets all requirements' do
      it 'does not show the password strength error' do
        post '/register', valid_params
        expect(last_response.body).not_to include('Password must contain')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Duplicate username
  # ---------------------------------------------------------------------------

  describe 'username uniqueness' do
    context 'when the username is already taken' do
      it 'returns 200 and shows the taken username error' do
        # Register the username once successfully
        post '/register', valid_params
        # Attempt to register the same username again
        post '/register', valid_params.merge('email' => 'other@example.com')
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('That username is already taken')
      end

      it 'shows the submission error banner' do
        post '/register', valid_params
        post '/register', valid_params.merge('email' => 'other@example.com')
        expect(last_response.body).to include('Please correct the errors below')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Empty form submission (no params)
  # ---------------------------------------------------------------------------

  describe 'empty form submission' do
    context 'when no params are submitted' do
      it 'returns 200 and does not show any validation errors' do
        post '/register', {}
        expect(last_response.status).to eq(200)
        expect(last_response.body).not_to include('Please correct the errors below')
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Multiple errors
  # ---------------------------------------------------------------------------

  describe 'multiple validation errors' do
    context 'when username, password, and email are all invalid' do
      it 'shows all relevant errors at once' do
        post '/register', {
          'uname' => '',
          'email' => 'bademail',
          'pword' => 'weak',
          'confirmpword' => 'nomatch'
        }
        expect(last_response.body).to include('Please enter a username')
        expect(last_response.body).to include('Please enter a valid email')
        expect(last_response.body).to include('Passwords dont match')
        expect(last_response.body).to include('Password must contain')
        expect(last_response.body).to include('Please correct the errors below')
      end
    end
  end
end
