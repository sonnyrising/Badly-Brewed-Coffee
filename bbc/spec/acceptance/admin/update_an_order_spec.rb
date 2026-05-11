RSpec.describe "Updating an order", type: :feature do
  context "when an admin is logged in" do
    it "updates order details" do
      
      user = Users.create(Username: "test_user", Email: "test@test.com")
      order = Transactions.create(
        UserId: user.UserId,
        TotalCost: 12.99,
        Address: "Old address",
        TransactionDate: 01012024,
        Refunded: "false"  
      )
      
      allow_any_instance_of(Sinatra::Base).to receive(:session).and_return({ user_id: 1, uname: 'admin' })

      visit "/admin/orders"

      within("div", text: order.TransactionId.to_s) do
        click_on "Edit"
      end

      fill_in "address-data", with: "New Address"
      fill_in "refund-data", with: "true"

      click_on "Save"

      expect(page).to have_current_path("/admin/orders")

      updated_order = Transactions[order.TransactionId]
      expect(updated_order.Address).to eq("New Address")
      expect(updated_order.Refunded).to eq("true")
    end
  end
end