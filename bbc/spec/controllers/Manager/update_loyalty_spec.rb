require_relative "../../spec_helper"

# =============================================================================
# Manager Controller Tests
# =============================================================================

RSpec.describe "Manager Controller Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  # ---------------------------------------------------------------------------
  # Authentication Tests
  # ---------------------------------------------------------------------------

  describe "Authentication Tests" do
    context "when not logged in as manager" do
      it "redirects staff away from /manager/homepage" do
        get "/manager/homepage", {}, staff_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/login")
      end

      it "redirects guests away from /manager/homepage" do
        get "/manager/homepage", {}, guest_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/login")
      end
    end
  end


  # ---------------------------------------------------------------------------
  # GET /manager/homepage
  # ---------------------------------------------------------------------------

  describe "GET /manager/homepage" do
    context "when logged in as manager" do
      it "returns 200" do
        get "/manager/homepage", {}, manager_session
        expect(last_response.status).to eq(200)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET /manager/adjustloyalty
  # ---------------------------------------------------------------------------

  describe "GET /manager/adjustloyalty" do
    context "when logged in as manager" do
      it "returns 200" do
        get "/manager/adjustloyalty", {}, manager_session
        expect(last_response.status).to eq(200)
      end

      it "lists non-suspended users" do
        get "/manager/adjustloyalty", {}, manager_session
        expect(last_response.body).to include("testuser")
      end
    end

    context "when not logged in as manager" do
      it "redirects to /login" do
        get "/manager/adjustloyalty", {}, guest_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/login")
      end
    end
  end


  # ---------------------------------------------------------------------------
  # GET /manager/viewfeedback
  # ---------------------------------------------------------------------------

  describe "GET /manager/viewfeedback" do
    context "when no filter is applied" do
      it "returns 200" do
        get "/manager/viewfeedback", {}, manager_session
        expect(last_response.status).to eq(200)
      end

      it "displays all feedback entries" do
        get "/manager/viewfeedback", {}, manager_session
        expect(last_response.body).to include("General issue")
      end
    end

    context "when filter is set to refund" do
      it "returns 200" do
        get "/manager/viewfeedback?filter=refund", {}, manager_session
        expect(last_response.status).to eq(200)
      end

      it "shows only refund feedback" do
        get "/manager/viewfeedback?filter=refund", {}, manager_session
        expect(last_response.body).to include("General issue")
      end
    end

    context "when not logged in as manager" do
      it "redirects to /login" do
        get "/manager/viewfeedback", {}, guest_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/login")
      end
    end
  end


  # ---------------------------------------------------------------------------
  # Update discount tests
  # ---------------------------------------------------------------------------

  describe "Update discount tests" do

    let(:manager_session) { { 'rack.session' => { userId: 1, uname: 'manager' } } }

    context "when no discount param" do
      it "returns 200 with error" do
        post "/manager/updatediscount", { 'user_id' => "1" }, manager_session
        puts "--- DEBUG INFO ---"
        puts "STATUS: #{last_response.status}"
        puts "LOCATION (if redirected): #{last_response.location}"
        puts "BODY: #{last_response.body}"
        puts "------------------"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Please enter a valid discount percentage (0-100).")
      end
    end

    context "when discount is blank" do
      it "returns 200 with error" do
        post "/manager/updatediscount", { 'user_id' => "1", 'discount' => "" }, manager_session
        puts "--- DEBUG INFO ---"
        puts "STATUS: #{last_response.status}"
        puts "LOCATION (if redirected): #{last_response.location}"
        puts "BODY: #{last_response.body}"
        puts "------------------"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Please enter a valid discount percentage (0-100).")
      end
    end

    context "when discount is non-numeric" do
      it "returns 200 with error for letters" do
        post "/manager/updatediscount", { 'user_id' => "1", 'discount' => "free" }, manager_session
        puts "--- DEBUG INFO ---"
        puts "STATUS: #{last_response.status}"
        puts "LOCATION (if redirected): #{last_response.location}"
        puts "BODY: #{last_response.body}"
        puts "------------------"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Please enter a valid discount percentage (0-100).")
      end

      it "returns 200 with error for float" do
        post "/manager/updatediscount", { 'user_id' => "1", 'discount' => "10.5" }, manager_session
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Please enter a valid discount percentage (0-100).")
      end
    end

    context "when discount is out of range" do
      it "returns 200 with error for 101" do
        post "/manager/updatediscount", { 'user_id' => "1", 'discount' => "101" }, manager_session
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Please enter a valid discount percentage (0-100).")
      end
    end

    context "when discount is valid" do
      [0, 50, 100].each do |value|
        it "updates DB and redirects for #{value}" do
          post "/manager/updatediscount", { 'user_id' => "1", 'discount' => value.to_s }, manager_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).to include("/manager/adjustloyalty")
          expect(Users.where(UserId: 1).first[:LoyaltyDiscount]).to eq(value)
        end
      end
    end
  end
end