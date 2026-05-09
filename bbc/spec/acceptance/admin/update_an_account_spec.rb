RSpec.describe "Updating an account" do
  context "when an admin is logged in" do
    it "updates account details" do
      account = Users.create(
        Username: "alice",
        Email: "alice@example.com",
        LoyaltyPoints: 120,
        DaysSinceLastUse: 5
      )

      visit "/admin/accounts/edit/#{account.UserId}"

      fill_in "username-data", with: "alice_new"
      fill_in "email-data", with: "alice_new@example.com"
      fill_in "loyaltypoint-data", with: "200"
      fill_in "address-data", with: "123 Street"
      fill_in "inactivity-data", with: "10"

      click_on "Save"

      expect(page).to have_current_path("/admin/accounts/#{account.UserId}")
      expect(page).to have_content("alice_new")
      expect(page).to have_content("alice_new@example.com")
      expect(page).to have_content("200")
      expect(page).to have_content("10")
    end

    it "resets the password" do
      account = Users.create(
        Username: "jeff",
        Email: "jeff@example.com",
        LoyaltyPoints: 50,
        DaysSinceLastUse: 2
      )

      visit "/admin/accounts/edit/#{account.UserId}"

      click_on "Reset password"

      expect(page).to have_current_path("/admin/accounts/#{account.UserId}")
      #expect(page).to have_content("Password reset")
    end
  end
end
