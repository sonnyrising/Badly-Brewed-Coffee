require_relative '../spec_helper'

# =============================================================================
# Authentication Tests
# =============================================================================
RSpec.describe "Authentication Tests" do

  let(:admin_session)   { { 'rack.session' => { user_id: 1, uname: 'admin' } } }
  let(:manager_session) { { 'rack.session' => { user_id: 2, uname: 'manager' } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil } } }

  admin_get_routes = [
    "/admin",
    "/admin/accounts",
    "/admin/views",
    "/admin/feedback",
    "/admin/run-inactivity-check",
  ]

  admin_post_routes = [
    "/admin/views/manager",           "/admin/views/barista",
    "/admin/views/user",              "/admin/feedback/filter",
    "/admin/feedback/delete",         "/admin/accounts/create",
    "/admin/accounts/create/submit",  "/admin/accounts/filter",
    "/admin/accounts/view",           "/admin/accounts/edit",
    "/admin/accounts/edit/update",
  ]

  test_params = { userId: 1, feedbackId: 1, 
                  'id-data': 1, 'search-filter': 'test'  }

  admin_get_routes.each do |route| 
    describe "GET #{route}" do

      context "when logged in as an admin" do
        it "has a status code of 200 (OK)" do
          get route, {}, admin_session
          expect(last_response.status).to eq(200)
        end
      end
      
      context "when logged in as manager" do
        it "denies access and redirects (302)" do
          get route, {}, manager_session
          expect(last_response.status).to eq(302)
        end
      end

      context "when not logged in" do
        it "denies access and redirects (302)" do
          get route, {}, guest_session
          expect(last_response.status).to eq(302)
        end
      end
    end
  end

  admin_post_routes.each do |route|
    describe "POST #{route}" do

      context "logged in as an admin" do
        it "allows the admin to perform the operations" do
          post route, test_params, admin_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).not_to eq("http://example.org/")
        end
      end

      context "not logged in as an admin" do
        it "denies access and redirects" do
          post route, test_params, admin_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).to eq("http://example.org/")
        end
      end
    end
  end
end

# =============================================================================
# Viewing Feedback Tests
# =============================================================================
RSpec.describe "Feedback Listing Tests" do

  let(:admin_session)   { { 'rack.session' => { user_id: 1, uname: 'admin' } } }

  context "no filter is applied" do
    it "returns 200 and displays all feedback entries" do
      get "/admin/feedback", {}, admin_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("General issue")
      expect(last_response.body).to include("Ticket : 1001")
      expect(last_response.body).to include("Reason : Test reason")    
    end
  end

  context "filter is applied" do
    it "returns 200 and displays all refund feedback entries" do
      post "/admin/feedback/filter", {}, admin_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Ticket : 1001")
      expect(last_response.body).to include("Reason : Test reason")
    end
  end

  context "deleting a feedback entry" do
    it "successfully deletes a feedback entry and redirects" do
      expect(Feedbacks.where(FeedbackId: 1).count).to eq(1)
      post "/admin/feedback/delete", { feedbackId: 1 }, admin_session
      expect(last_response.status).to eq(200)
      expect(last_response.location).to eq("/admin/feedback")
      expect(Feedbacks.where(FeedbackId: 1).count).to eq(0)
    end
  end
end