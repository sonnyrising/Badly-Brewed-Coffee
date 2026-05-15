# frozen_string_literal: true

RSpec.describe 'Updating an account' do
  context 'when an admin is logged in' do
    it 'updates account details' do
      account = Users.create(
        Username: 'alice',
        Email: 'alice@example.com',
        LoyaltyPoints: 120,
        DaysSinceLastUse: 5
      )

      login_as_admin

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
  end
end
