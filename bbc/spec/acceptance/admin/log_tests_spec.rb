RSpec.describe 'Updating an order', type: :feature do

  context 'when an admin is logged in' do

    it 'updates order details' do
      login_as_admin
      user = Users.create(Username: 'test_user', Email: 'test@test.com')
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        Address: 'Old address',
        TransactionDate: 01012024,
        Refunded: 'false'
      )

      visit '/admin/orders'

      find(:xpath, "//form[input[@value='#{order.TransactionId}'] and @action='/admin/orders/edit']//button").click

      fill_in 'address-data', with: 'New Address'
      fill_in 'refund-data', with: 'true'
      fill_in 'refund-reason', with: 'This is a test log entry'

      click_on 'Save'

      visit '/admin/log'

      expect(page).to have_current_path('/admin/log')

      expect(page).to have_content("This is a test log entry")
    end
  end
end