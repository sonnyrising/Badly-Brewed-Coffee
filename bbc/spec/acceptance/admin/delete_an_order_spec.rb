# frozen_string_literal: true

RSpec.describe 'Admin deleting an order', type: :feature do
  it 'allows an admin to delete an order entry from database' do
    user = Users.create(Username: 'test_name', Email: 'test@test.com')
    order = Transactions.create(
      UserId: user.UserId,
      TotalCost: 12.99,
      TransactionDate: 0o1012024,
      Status: 'Pending'
    )

    login_as_admin

    visit '/admin/orders'

    find(:xpath, "//form[input[@value='#{order.TransactionId}'] and @action='/admin/orders/delete']//button").click


    expect(page).to have_current_path('/admin/orders')
    expect(Transactions[order.TransactionId]).to be_nil
  end
end
