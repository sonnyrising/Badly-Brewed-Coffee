require_relative '../../spec_helper'

RSpec.describe 'GET /user/settings' do

  # Logged in user setup

  before do
    post '/register', {
      'uname' => 'Settings',
      'email' => 'settings@mail.com',
      'pword' => 'Password123!',
      'confirmpword' => 'Password123!'
    }
  end

  # Settings page access

  describe 'successful settings page access' do
    context 'when the user is logged in' do
      it 'returns 200' do
        get '/user/settings'
        expect(last_response.status).to eq(200)
      end

      it 'renders the settings page' do
        get '/user/settings'
        expect(last_response.body).to include('settings')
      end
    end
  end

  # Success and error session messages

  describe 'session messages' do
    context 'when a success message exists in the session' do
      it 'loads the page successfully' do
        last_request.session[:success_message] = 'Updated successfully'

        get '/user/settings'

        expect(last_response.status).to eq(200)
      end
    end

    context 'when an error message exists in the session' do
      it 'loads the page successfully' do
        last_request.session[:error_message] = 'Something went wrong'

        get '/user/settings'

        expect(last_response.status).to eq(200)
      end
    end
  end
end

#Test to update settings

RSpec.describe 'POST /user/update_settings' do

  before do
    post '/register', {
      'uname' => 'originalUser',
      'email' => 'original@mail.com',
      'pword' => 'Password123!',
      'confirmpword' => 'Password123!'
    }
  end

  let(:valid_update_params) do
    {
      'username' => 'updateduser',
      'email' => 'updated@mail.com'
    }
  end

  #Successful update

  describe 'successful settings update' do
    context 'when username and email are unique' do
      it 'redirects back to settings' do
        post '/user/update_settings', valid_update_params

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/user/settings')
      end

      it 'updates username in the session' do
        post '/user/update_settings', valid_update_params

        expect(last_request.session[:uname]).to eq('updateduser')
      end

      it 'sets a success message' do
        post '/user/update_settings', valid_update_params

        expect(last_request.session[:success_message])
          .to include('Account details successfully updated!')
      end

      it 'updates user in the database' do
        post '/user/update_settings', valid_update_params

        updated_user = Users.where(Username: 'updateduser').first

        expect(updated_user).not_to be_nil
        expect(updated_user.Email).to eq('updated@mail.com')
      end
    end
  end

  #Duplicate username change

  describe 'duplicate username validation' do
    before do
      post '/register', {
        'uname' => 'takenUser',
        'email' => 'taken@mail.com',
        'pword' => 'Password1!',
        'confirmpword' => 'Password1!'
      }

      #Log back into original account
      post '/login', {
        'uname' => 'originalUser',
        'pword' => 'Password123!'
      }
    end

    context 'when the username is already taken' do
      it 'redirects back to settings' do
        post '/user/update_settings', {
          'username' => 'takenUser',
          'email' => 'newemail@mail.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/user/settings')
      end

      it 'sets the username taken error message' do
        post '/user/update_settings', {
          'username' => 'takenUser',
          'email' => 'newemail@mail.com'
        }

        expect(last_request.session[:error_message])
          .to include("Sorry, the username 'takenUser' is already taken!")
      end
    end
  end

  #Duplicate email change

  describe 'duplicate email validation' do
    before do
      post '/register', {
        'uname' => 'anotherUser',
        'email' => 'takenemail@mail.com',
        'pword' => 'Password123!',
        'confirmpword' => 'Password123!'
      }

      post '/login', {
        'uname' => 'originalUser',
        'pword' => 'Password123!'
      }
    end

    context 'when the email is already taken' do
      it 'redirects back to settings' do
        post '/user/update_settings', {
          'username' => 'newUsername',
          'email' => 'takenemail@mail.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/user/settings')
      end

      it 'sets the email taken error message' do
        post '/user/update_settings', {
          'username' => 'newUsername',
          'email' => 'takenemail@mail.com'
        }

        expect(last_request.session[:error_message])
          .to include("Sorry, the email 'takenemail@mail.com' is already taken!")
      end
    end
  end

end
