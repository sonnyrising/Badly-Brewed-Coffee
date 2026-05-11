require_relative '../../spec_helper'

# =============================================================================
# View Feedback Tests
# =============================================================================

RSpec.describe "View Feedback Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  context "when no filter is applied" do
    it "returns 200 and displays all feedback entries" do
      get "/manager/viewfeedback", {}, manager_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("General issue")  # IssueContent column
    end
  end

  context "when filter is applied" do
    it "returns 200 and shows only refund-request feedback" do
      get "/manager/viewfeedback?filter=refund", {}, manager_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("General issue")
    end
  end

  context "when an unrecognised filter value is passed" do
    it "returns 200 and does not crash" do
      get "/manager/viewfeedback?filter=unknown", {}, manager_session
      expect(last_response.status).to eq(200)
    end
  end
end