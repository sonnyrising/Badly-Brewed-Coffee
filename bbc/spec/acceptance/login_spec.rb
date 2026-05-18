# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'

require_relative '../spec_helper'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

RSpec.describe 'Login Tests', type: :feature do
  def attempt_login(username, password)
    visit '/login'
    fill_in 'username', with: username
    fill_in 'password', with: password
    click_button 'Log in'
  end

  # -------------------------------------------------------------------------
  # Valid logins — each user type
  # -------------------------------------------------------------------------

  describe 'Valid credentials' do
    context 'when logging in as a manager' do
      before { attempt_login('Manager123!', 'Manager123!') }

      it 'logs in successfully' do
        expect(page.current_path).not_to eq('/login')
      end

      it 'redirects to the manager area' do
        expect(page.current_path).to start_with('/manager').or start_with('/homepage')
      end
    end

    context 'when logging in as staff' do
      before { attempt_login('Staff123!', 'Staff123!') }

      it 'logs in successfully' do
        expect(page.current_path).not_to eq('/login')
      end

      it 'redirects to the staff area' do
        expect(page.current_path).to start_with('/staff').or start_with('/homepage')
      end
    end

    context 'when logging in as admin' do
      before { attempt_login('Admin123!', 'Admin123!') }

      it 'logs in successfully' do
        expect(page.current_path).not_to eq('/login')
      end
    end

    context 'when logging in as a regular user' do
      before { attempt_login('User123!', 'User123!') }

      it 'logs in successfully' do
        expect(page.current_path).not_to eq('/login')
      end

      it 'redirects to the user area' do
        expect(page.current_path).to start_with('/user').or start_with('/homepage')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Invalid credentials
  # -------------------------------------------------------------------------

  describe 'Invalid credentials' do
    context 'when the username does not exist' do
      before { attempt_login('nonexistentuser', 'password') }

      it 'stays on the login page' do
        expect(page.current_path).to eq('/login')
      end

      it 'shows an error message' do
        expect(page).to have_content(/incorrect|please/i)
      end
    end

    context 'when the password is wrong' do
      before { attempt_login('Manager123!', 'wrongpassword') }

      it 'stays on the login page' do
        expect(page.current_path).to eq('/login')
      end

      it 'shows an error message' do
        expect(page).to have_content(/incorrect|please/i)
      end
    end

    context 'when the username is blank' do
      before { attempt_login('', 'Manager123!') }

      it 'stays on the login page' do
        expect(page.current_path).to eq('/login')
      end
    end

    context 'when the password is blank' do
      before { attempt_login('Manager123!', '') }

      it 'stays on the login page' do
        expect(page.current_path).to eq('/login')
      end
    end

    context 'when both fields are blank' do
      before { attempt_login('', '') }

      it 'stays on the login page' do
        expect(page.current_path).to eq('/login')
      end
    end

    context 'when the correct username is used with a blank password' do
      before { attempt_login('Manager123!', '') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end
    end

    context 'when the password is correct but the username case is wrong' do
      before { attempt_login('manager123!', 'Manager123!') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end
    end
  end

  # -------------------------------------------------------------------------
  # SQL injection attempts
  # -------------------------------------------------------------------------

  describe 'SQL injection attempts' do
    context 'when the username contains a classic OR 1=1 injection' do
      before { attempt_login("' OR '1'='1", 'anything') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when the username contains a comment-based injection' do
      before { attempt_login("Manager123!'--", 'anything') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when the username contains a UNION-based injection' do
      before { attempt_login("' UNION SELECT * FROM Users--", 'anything') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when the password contains a SQL injection attempt' do
      before { attempt_login('Manager123!', "' OR '1'='1") }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when both fields contain injection attempts' do
      before { attempt_login("' OR 1=1--", "' OR 1=1--") }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end
  end

  # -------------------------------------------------------------------------
  # HTML injection attempts
  # -------------------------------------------------------------------------

  describe 'HTML injection attempts' do
    context 'when the username contains a script tag' do
      before { attempt_login('<script>alert("xss")</script>', 'password') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not render the script tag unescaped' do
        expect(page.body).not_to include('<script>alert("xss")</script>')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when the username contains an img onerror XSS payload' do
      before { attempt_login('<img src=x onerror=alert(1)>', 'password') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not render the payload unescaped' do
        expect(page.body).not_to include('<img src=x onerror=alert(1)>')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end

    context 'when the username contains HTML special characters' do
      before { attempt_login('<b>Admin123!</b>', 'Admin123!') }

      it 'does not log in' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not crash the application' do
        expect(page.status_code).to be < 500
      end
    end
  end

  # -------------------------------------------------------------------------
  # Session behaviour
  # -------------------------------------------------------------------------

  describe 'Session behaviour' do
    context 'after a successful login' do
      before { attempt_login('Manager123!', 'Manager123!') }

      it 'does not leave the user on the login page' do
        expect(page.current_path).not_to eq('/login')
      end
    end

    context 'after visiting the landing page' do
      before do
        attempt_login('Manager123!', 'Manager123!')
        visit '/landingpage'
      end

      it 'clears the session and returns to the landing page' do
        expect(page.current_path).to eq('/landingpage')
        visit '/manager/homepage'
        expect(page.current_path).to eq('/login')
      end
    end

    context 'after visiting the root path' do
      it 'redirects to the landing page' do
        visit '/'
        expect(page).to have_current_path('/landingpage')
      end
    end
  end
end
