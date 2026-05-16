RSpec.describe 'When managing orders', type: :feature do

  context 'when an admin is logged in' do

    it 'it updates order details' do
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

      click_on 'Save'

      expect(page).to have_current_path('/admin/orders')

      updated_order = Transactions[order.TransactionId]
      expect(updated_order.Address).to eq('New Address')
      expect(updated_order.Refunded).to eq(true)
    end

    it 'it deletes an order entry from the database' do
      login_as_admin
      user = Users.create(Username: 'test_name', Email: 'test@test.com')
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        TransactionDate: 01012024,
        Status: 'Pending'
      )

      visit '/admin/orders'

      find(:xpath, "//form[input[@value='#{order.TransactionId}'] and @action='/admin/orders/delete']//button").click


      expect(page).to have_current_path('/admin/orders')
      expect(Transactions[order.TransactionId]).to be_nil
    end
  end
end
