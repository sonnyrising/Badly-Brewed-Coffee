require_relative '../../spec_helper'

# =============================================================================
# Order Management Tests
# =============================================================================
RSpec.describe "Order Management Logic" do
  let(:admin_session) { { 'rack.session' => { user_id: 1, uname: 'admin' } } }

  it "displays all order entries" do
    get "/admin/orders", {}, admin_session
    expect(last_response.status).to eq(200)
  end
  
  it "updates order details correctly" do
    Transactions.insert(TransactionId: 500, UserId: 1, Address: "Old address", TotalCost: 5.00)

    post "/admin/orders/edit/update", {
      'order-data': 500,
      'address-data': "New address",
      'refund-data': true
    }, admin_session

    expect(last_response.status).to eq(302)
    expect(Transactions[500].Address).to eq("New address")
  end

  it "deletes an order from database" do
    Transactions.insert(TransactionId: 501, UserId: 1, TotalCost: 10.00)
    expect(Transactions[501]).not_to be_nil

    post "/admin/orders/delete", { 'transaction-id': 501 }, admin_session

    expect(last_response.status).to eq(302)
    expect(Transactions[501]).to be_nil
  end

  context "searches an order" do
    it "it displays the searched order" do
      Transactions.insert(TransactionId: 502, UserId: 1, TotalCost: 10.00)

      post "/admin/orders/filter", { 'search-filter': "502" }, admin_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("admin/orders")
    end

    it "it redirects if searched order doesn't exist" do
      post "/admin/orders/filter", { 'search-filter': "400" }, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.body).to include("admin/orders")
    end
  end
end