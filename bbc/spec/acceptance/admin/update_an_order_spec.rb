# frozen_string_literal: true

RSpec.describe 'Updating an order', type: :feature do
  context 'when an admin is logged in' do
    it 'updates order details' do
      user = Users.create(Username: 'test_user', Email: 'test@test.com')
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        Address: 'Old address',
        TransactionDate: 01012024,
        Refunded: 'false'
      )

      login_as_admin

      visit '/admin/orders'

      find(:xpath, "//form[input[@value='#{order.TransactionId}'] and @action='/admin/orders/edit']//button").click

      fill_in 'address-data', with: 'New Address'
      fill_in 'refund-data', with: 'true'

      click_on 'Save'

      expect(page).to have_current_path('/admin/orders')

      updated_order = Transactions[order.TransactionId]
      expect(updated_order.Address).to eq('New Address')
      expect(updated_order.Refunded).to eq(true)
    end
  end
end
