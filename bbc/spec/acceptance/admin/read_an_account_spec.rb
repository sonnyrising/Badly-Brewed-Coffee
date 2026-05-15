# frozen_string_literal: true

RSpec.describe 'Viewing an account' do
  context 'when the admin is logged in' do
    it 'shows account details and transaction history' do
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

      login_as_admin

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
  end
end
