require_relative '../../spec_helper'

RSpec.describe 'When managing accounts' do

  context 'when the admin is logged in' do

    it 'it creates a new staff account' do
      login_as_admin
      visit '/admin/accounts/create'

      choose 'staffoption'

      fill_in 'username-data', with: 'teststaff123'
      fill_in 'email-data', with: 'teststaff@example.com'
      fill_in 'loyaltypoint-data', with: '100'

      click_on "Save"
      
      expect(page).to have_current_path("/admin/accounts")
      expect(page).to have_content("teststaff123")
    end

    it 'it creates a new user account' do
      login_as_admin
      visit '/admin/accounts/create'

      choose 'useroption'

      fill_in 'username-data', with: 'testuser123'
      fill_in 'email-data', with: 'testuser@example.com'
      fill_in 'loyaltypoint-data', with: '100'

      click_on "Save"
      
      expect(page).to have_current_path("/admin/accounts")
      expect(page).to have_content("testuser123")
    end

    it 'it shows account details' do
      login_as_admin
      account = Users.create(
        Username: 'alice',
        Email: 'alice@example.com',
        LoyaltyPoints: 120,
        DaysSinceLastUse: 5
      )

      Transactions.create(
        UserId: account.UserId,
        TotalCost: 49.99,
        TransactionDate: '01012024'
      )

      visit "/admin/accounts"

      find(:xpath, "//form[input[@value='#{account.UserId}'] and @action='/admin/accounts/view']//button").click

      expect(page).to have_content('alice')
      expect(page).to have_content(account.UserId)
      expect(page).to have_content('alice@example.com')
      expect(page).to have_content('120')
      expect(page).to have_content('5')

      expect(page).to have_content('Transaction history')
      expect(page).to have_content('£49.99')
    end

    it 'updates account details' do
      login_as_admin
      account = Users.create(
        Username: 'alice',
        Email: 'alice@example.com',
        LoyaltyPoints: 120,
        DaysSinceLastUse: 5
      )

      visit "/admin/accounts"

      find(:xpath, "//form[input[@value='#{account.UserId}'] and @action='/admin/accounts/edit']//button").click

      fill_in 'username-data', with: 'alice_new'
      fill_in 'email-data', with: 'alice_new@example.com'
      fill_in 'loyaltypoint-data', with: '200'
      fill_in 'address-data', with: '123 Street'
      fill_in 'inactivity-data', with: '10'

      click_on 'Save'

      find(:xpath, "//form[input[@value='#{account.UserId}'] and @action='/admin/accounts/view']//button").click

      expect(page).to have_current_path("/admin/accounts/view")
      expect(page).to have_content('alice_new')
      expect(page).to have_content('alice_new@example.com')
      expect(page).to have_content('200')
      expect(page).to have_content('10')
    end

    it 'deletes the account and associated data' do
      login_as_admin
      account = Users.create(
        Username: 'alice',
        Email: 'alice@example.com',
        LoyaltyPoints: 120,
        DaysSinceLastUse: 5
      )

      Feedbacks.create(UserId: account.UserId, IssueContent: 'hi')
      Basket.create(UserId: account.UserId)

      visit "/admin/accounts"

      find(:xpath, "//form[input[@value='#{account.UserId}'] and @action='/admin/accounts/delete']//button").click

      expect(page).to have_current_path('/admin/accounts')
      expect(Users[account.UserId]).to be_nil
      expect(Transactions.where(UserId: account.UserId).count).to eq(0)
      expect(Feedbacks.where(UserId: account.UserId).count).to eq(0)
      expect(Basket.where(UserId: account.UserId).count).to eq(0)
    end
  end
end