require_relative '../../spec_helper'

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