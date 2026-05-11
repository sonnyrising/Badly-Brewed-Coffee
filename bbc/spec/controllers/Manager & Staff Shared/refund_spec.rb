require_relative '../spec_helper'

# =============================================================================
# Refunds Tests
# =============================================================================

RSpec.describe "Refunds Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }

  describe "GET /refunds – page load" do
    context "when logged in as a manager" do
      it "returns 200 and shows the Pending Refunds heading" do
        get "/refunds", {}, manager_session
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include("Pending Refunds")
      end

      it "lists the refund-requested transaction" do
        get "/refunds", {}, manager_session
        expect(last_response.body).to include("15")
      end
    end

    context "when logged in as staff" do
      it "returns 200" do
        get "/refunds", {}, staff_session
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe "GET /refunds?message=accept" do
    context "when a valid refund_id is supplied" do
      it "sets Status to 'Refunded' in the database" do
        get "/refunds?message=accept&refund_id=2", {}, manager_session
        updated = Transactions.where(TransactionId: 2).first
        expect(updated[:Status]).to eq("Refunded")
      end

      it "sets Refunded to true" do
        get "/refunds?message=accept&refund_id=2", {}, manager_session
        updated = Transactions.where(TransactionId: 2).first
        expect(updated[:Refunded]).to be_truthy
      end

      it "clears the refundRequested flag" do
        get "/refunds?message=accept&refund_id=2", {}, manager_session
        updated = Transactions.where(TransactionId: 2).first
        expect(updated[:refundRequested]).to be_falsy
      end

      it "shows an acceptance confirmation banner on the page" do
        get "/refunds?message=accept&refund_id=2", {}, manager_session
        expect(last_response.body).to include("accepted")
      end
    end

    context "when a non-existent refund_id is supplied" do
      it "does not crash and returns 200" do
        get "/refunds?message=accept&refund_id=9999", {}, manager_session
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe "GET /refunds?message=decline" do
    context "when a valid refund_id is supplied" do
      it "clears the refundRequested flag" do
        get "/refunds?message=decline&refund_id=2", {}, manager_session
        updated = Transactions.where(TransactionId: 2).first
        expect(updated[:refundRequested]).to be_falsy
      end

      it "does NOT set Status to 'Refunded'" do
        get "/refunds?message=decline&refund_id=2", {}, manager_session
        updated = Transactions.where(TransactionId: 2).first
        expect(updated[:Status]).to_not eq("Refunded")
      end

      it "shows a decline confirmation banner on the page" do
        get "/refunds?message=decline&refund_id=2", {}, manager_session
        expect(last_response.body).to include("declined")
      end
    end
  end

  describe "GET /refunds with unrecognised message param" do
    it "ignores unknown message values and returns 200" do
      get "/refunds?message=hack&refund_id=2", {}, manager_session
      expect(last_response.status).to eq(200)
    end

    it "does not alter any transaction data" do
      transaction_before = Transactions.where(TransactionId: 2).first
      get "/refunds?message=hack&refund_id=2", {}, manager_session
      transaction_after  = Transactions.where(TransactionId: 2).first
      expect(transaction_before).to eq(transaction_after)
    end
  end
end


# =============================================================================
# Refund Details Tests
# =============================================================================

RSpec.describe "Refund Details Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }

  context "when a valid transaction_id is supplied" do
    it "returns 200" do
      get "/refunddetails?transaction_id=2", {}, manager_session
      expect(last_response.status).to eq(200)
    end

    it "displays the refund reason from the Feedbacks table" do
      get "/refunddetails?transaction_id=2", {}, manager_session
      expect(last_response.body).to include("Cold coffee")
    end

    it "displays the transaction cost" do
      get "/refunddetails?transaction_id=2", {}, manager_session
      expect(last_response.body).to include("15")
    end

    it "renders Accept and Decline action buttons" do
      get "/refunddetails?transaction_id=2", {}, manager_session
      expect(last_response.body).to include("Accept")
      expect(last_response.body).to include("Decline")
    end

    it "renders a Back link to /refunds" do
      get "/refunddetails?transaction_id=2", {}, manager_session
      expect(last_response.body).to include("/refunds")
    end

    it "is also accessible to staff" do
      get "/refunddetails?transaction_id=2", {}, staff_session
      expect(last_response.status).to eq(200)
    end
  end

  context "when no transaction_id param is supplied" do
    it "returns a non-500 status code" do
      get "/refunddetails", {}, manager_session
      expect(last_response.status).to_not eq(500)
    end
  end

  context "when the transaction id doesnt exist" do
    it "returns a non-500 status code" do
      get "/refunddetails?transaction_id=9999", {}, manager_session
      expect(last_response.status).to_not eq(500)
    end
  end

  context "when transaction id is not a number" do
    it "returns a non-500 status code" do
      get "/refunddetails?transaction_id=abc", {}, manager_session
      expect(last_response.status).to_not eq(500)
    end
  end
end