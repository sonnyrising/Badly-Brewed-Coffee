RSpec.describe "Admin account creation" do
  context "when the admin is logged in" do
    it "allows an admin to create a new account" do

        visit "/admin/accounts/create"

        choose "Staff"  

        fill_in "username-data", with: "testuser123"
        fill_in "email-data", with: "test@example.com"
        fill_in "loyaltypoint-data", with: "100"

        click_on "Save"
        
        expect(page).to have_current_path("/admin/accounts")
    end
  end
end