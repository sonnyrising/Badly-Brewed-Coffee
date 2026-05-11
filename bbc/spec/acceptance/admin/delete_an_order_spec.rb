RSpec.describe "Admin deleting an order", type: :feature do
  it "allows an admin to delete an order entry from database" do

      user = Users.create(Username: "test_name", Email: "test@test.com")
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        TransactionDate: 01012024,
        Status: "Pending"
      )

      allow_any_instance_of(Sinatra::Base).to receive(:session).and_return({ user_id: 1, uname: 'admin'})
      visit "/admin/orders"
      
      within("div", text: order.TransactionId.to_s) do
        click_on "Delete"
      end

      expect(page).to have_current_path("/admin/orders")
      expect(Transactions[order.TransactionId]).to be_nil
  end
end