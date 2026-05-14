# frozen_string_literal: true

require_relative '../../spec_helper'

def admin_dummy
  Users.insert(UserId: 1, Username: 'admin', AccountType: 'admin')
end

# =============================================================================
# Accounts Page Tests
# =============================================================================
RSpec.describe 'Accounts page' do
  let(:admin_session) { { 'rack.session' => { userId: 1, uname: 'admin' } } }

  context 'When visiting the accounts page,' do
    it 'it displays all existing accounts' do
      Users.dataset.delete
      admin_dummy
      get '/admin/accounts', {}, admin_session
      expect(last_response.status).to eq(200)
    end
  end

  context 'When deleting an account,' do
    it 'it deletes the user entry from database' do
      Transactions.dataset.delete
      Basket.dataset.delete
      Users.dataset.delete

      admin_dummy
      Users.insert(UserId: 2, Username: 'test')
      Transactions.insert(TransactionId: 1, UserId: 2)
      Basket.insert(UserId: 2, BasketId: 1)

      expect(Users[1]).not_to be_nil
      expect(Transactions[UserId: 2]).not_to be_nil

      post '/admin/accounts/delete', { 'account-data' => 2 }, admin_session

      expect(last_response.status).to eq(302)
      expect(Users[2]).to be_nil
      expect(Transactions[UserId: 2]).to be_nil
      expect(Basket[UserId: 2]).to be_nil
    end
  end

  context 'When searching for an account,' do
    it 'it redirects if search bar is empty' do
      Users.dataset.delete
      admin_dummy
      post '/admin/accounts/filter', { 'search-filter': '' }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('admin/accounts')
    end

    it 'it displays the searched account' do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'johntest')

      post '/admin/accounts/filter', { 'search-filter': 'johntest' }, admin_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('admin/accounts')
    end

    it "it redirects if the searched account doesn't exist" do
      Users.dataset.delete
      admin_dummy
      post '/admin/accounts/filter', { 'search-filter': 'john' }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('admin/accounts')
    end
  end

  context 'When viewing a specific account,' do
    it "displays the account's details" do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'johntest')
      post '/admin/accounts/view', { 'account-data' => '2' }, admin_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('johntest')
    end

    it "it redirects if user account doesn't exist" do
      Users.dataset.delete
      admin_dummy
      post '/admin/accounts/view', { 'account-data' => '999' }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/admin/accounts/view')
    end

    it 'it verifies blank account page' do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'new user')
      get '/admin/accounts/view', { 'account-data' => 2 }, admin_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('new user')
    end
  end

  context 'When suspending an account,' do
    it 'it resets warning and suspension data when reset button is pressed' do
      Users.dataset.delete
      admin_dummy
      Users.insert(
        UserId: 10,
        Username: 'warned user',
        Suspended: 1,
        Warning: 1,
        DaysSinceWarning: 5
      )

      post '/admin/accounts/suspend', { 'account-data' => 10, 'button-type-data' => 'end-warning' }, admin_session
      updated_account = Users[10]
      expect(updated_account.Suspended).to eq(0)
      expect(updated_account.Warning).to eq(0)
      expect(updated_account.DaysSinceWarning).to eq(0)

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/admin/accounts')
    end

    it 'it reinstates the account if suspended' do
      Users.dataset.delete
      admin_dummy
      Users.insert(
        UserId: 10,
        Username: 'warned user',
        Suspended: 1
      )

      post '/admin/accounts/suspend', { 'account-data' => 10 }, admin_session
      updated_account = Users[10]
      expect(updated_account.Suspended).to eq(0)

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include('/admin/accounts')
    end

    it 'it sets a warning status on the account' do
      Users.dataset.delete
      admin_dummy
      Users.insert(
        UserId: 10,
        Username: 'warned user',
        Warning: 0,
        DaysSinceWarning: 0
      )

      post '/admin/accounts/suspend', { 'account-data' => 10 }, admin_session
      updated_account = Users[10]
      expect(updated_account.Warning).to eq(1)
      expect(last_response.status).to eq(302)
    end

    it 'it suspends the account if already on warning' do
      Users.dataset.delete
      admin_dummy
      Users.insert(
        UserId: 10,
        Username: 'warned user',
        Warning: 1,
        DaysSinceWarning: 0,
        Suspended: 0
      )

      post '/admin/accounts/suspend', { 'account-data' => 10 }, admin_session
      updated_account = Users[10]
      expect(updated_account.Suspended).to eq(1)
      expect(last_response.status).to eq(302)
    end
  end

  context "When editing an account's details" do
    it "it displays the account editing page for a specific account" do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'johntest')
      get "/admin/accounts/edit/2", { 'id' => "2" }, admin_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("2")
    end

    it "it redirects if the account doesn't exist" do
      Users.dataset.delete
      admin_dummy
      get "/admin/accounts/edit/2", { 'id' => "2" }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/admin/accounts")
    end

    it "it verifies the return page" do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'johntest')
      post "/admin/accounts/edit", { 'account-data' => "2" }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/admin/accounts/edit/2")
    end

    it "it changes the user account's password" do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 2, Username: 'johntest', PassHash: 'password')
      post "/admin/accounts/edit/recover", { 'account-data' => "2" }, admin_session

      updated_account = Users[2]
      stored_hash = BCrypt::Password.new(updated_account.PassHash)

      expect(stored_hash).to eq('password')
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/admin/accounts")
    end

    it "it updates the user account's details with the new ones" do
      Users.dataset.delete
      admin_dummy
      Users.insert(UserId: 10, Username: 'johntest', Email: 'johntest@test.com', 
                    LoyaltyPoints: 5, DaysSinceLastUse: 0)

      post "/admin/accounts/edit/update", {
        'account-data' => "10",
        'username-data' => "JohnTest",
        'email-data'  => "johntest@gmail.com",
        'loyaltypoint-data' => "10",
        'inactivity-data' => "5"
      }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/admin/accounts")

      expect(Users[10].Username).to eq("JohnTest")
      expect(Users[10].Email).to eq("johntest@gmail.com")
      expect(Users[10].LoyaltyPoints).to eq(10)
      expect(Users[10].DaysSinceLastUse).to eq(5)
    end
  end
end
