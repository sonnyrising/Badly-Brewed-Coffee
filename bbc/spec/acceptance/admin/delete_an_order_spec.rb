RSpec.describe "Admin deleting an order", type: :feature do
  it "allows an admin to delete an order entry from database" do

      user = Users.create(Username: "test_name", Email: "test@test.com")
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        TransactionDate: 01012024,
        Status: "Pending"
      )

      visit "/admin/orders"
      
      click_on "Delete"
      

      expect(page).to have_current_path("/admin/orders")
      expect(Transactions[order.TransactionId]).to be_nil
  end
end