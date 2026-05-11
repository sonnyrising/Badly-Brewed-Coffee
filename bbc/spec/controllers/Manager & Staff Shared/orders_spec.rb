require_relative '../../spec_helper'

# =============================================================================
# Orders and Status Tests
# =============================================================================

RSpec.describe "Orders Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }

  describe "GET /orders" do
    context "when logged in as a manager" do
      it "returns 200 and renders the Orders heading" do
        get "/orders", {}, manager_session
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Orders")
      end
    end

    context "when logged in as staff" do
      it "returns 200" do
        get "/orders", {}, staff_session
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe "POST /updatestatus" do
    valid_statuses = %w[Pending Processing Completed Collected Cancelled Refunded]

    valid_statuses.each do |status|
      context "When status is set to '#{status}'" do
        it "updates the transaction status in the database and redirects to /orders" do
          post "/updatestatus",
               { 'transaction_id' => "1", 'status' => status },
               manager_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).to include("/orders")
          updated = Transactions.where(TransactionId: 1).first
          expect(updated[:Status]).to eq(status)
        end
      end
    end

    context "When a SQL injection is attempted in the status field" do
      it "does update the db" do
        post "/updatestatus",
             { 'transaction_id' => "1", 'status' => "'; DROP TABLE transactions;--" },
             manager_session
        expect(Transactions.count).to be >= 1
      end
    end

    context "When transaction_id does not exist" do
      it "redirects to /orders without crashing" do
        post "/updatestatus",
             { 'transaction_id' => "9999", 'status' => "Completed" },
             manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/orders")
      end
    end
  end
end