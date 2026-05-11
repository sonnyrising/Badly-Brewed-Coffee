require_relative "../../spec_helper"

# =============================================================================
# Update Loyalty Discount Tests
# =============================================================================

RSpec.describe "Update Loyalty Discount Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  test_cases = [
    {
      description: "Valid discount – lower boundary (0)",
      params: { 'user_id' => "1", 'discount' => "0" },
      expect_redirect: true,
      expect_error:    false
    },
    {
      description: "Valid discount – mid value (50)",
      params: { 'user_id' => "1", 'discount' => "50" },
      expect_redirect: true,
      expect_error:    false
    },
    {
      description: "Valid discount – upper boundary (100)",
      params: { 'user_id' => "1", 'discount' => "100" },
      expect_redirect: true,
      expect_error:    false
    },
    {
      description: "Invalid discount – negative value (-1)",
      params: { 'user_id' => "1", 'discount' => "-1" },
      expect_redirect: false,
      expect_error:    true,
      error_message:   "Please enter a valid discount percentage (0-100)."
    },
    {
      description: "Invalid discount – exceeds maximum (101)",
      params: { 'user_id' => "1", 'discount' => "101" },
      expect_redirect: false,
      expect_error:    true,
      error_message:   "Please enter a valid discount percentage (0-100)."
    },
    {
      description: "Invalid discount – non-numeric string",
      params: { 'user_id' => "1", 'discount' => "free" },
      expect_redirect: false,
      expect_error:    true,
      error_message:   "Please enter a valid discount percentage (0-100)."
    },
    {
      description: "Invalid discount – nil",
      params: { 'user_id' => "1" },
      expect_redirect: false,
      expect_error:    true,
      error_message:   "Please enter a valid discount percentage (0-100)."
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do

      it "is accessible only by a manager (staff is redirected with 302)" do
        post "/manager/updatediscount", test_case[:params], staff_session
        expect(last_response.status).to eq(302)
      end

      it "is inaccessible when not logged in (redirected with 302)" do
        post "/manager/updatediscount", test_case[:params], guest_session
        expect(last_response.status).to eq(302)
      end

      if test_case[:expect_redirect]
        it "redirects to /manager/adjustloyalty after a successful update" do
          post "/manager/updatediscount", test_case[:params], manager_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).to include("/manager/adjustloyalty")
        end

        it "updates the database" do
          post "/manager/updatediscount", test_case[:params], manager_session
          updated = Users.where(UserId: test_case[:params]['user_id'].to_i).first
          expect(updated[:LoyaltyDiscount]).to eq(test_case[:params]['discount'].to_i)
        end
      end

      if test_case[:expect_error]
        it "returns a 200 with an error message" do
          post "/manager/updatediscount", test_case[:params], manager_session
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include(test_case[:error_message])
        end

        it "does not change the database" do
          discount_before = Users.where(UserId: 1).first[:LoyaltyDiscount]
          post "/manager/updatediscount", test_case[:params], manager_session
          discount_after = Users.where(UserId: 1).first[:LoyaltyDiscount]
          expect(discount_before).to eq(discount_after)
        end
      end
    end
  end
end