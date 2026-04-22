require_relative '../spec_helper'

require_relative '../spec_helper'

RSpec.describe "Authentication Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, role: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, role: 'staff' } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, role: nil } } }

  manager_routes = [
    "/manager/homepage",
    "/manager/managestock",
    "/manager/addproduct",
    "/manager/beanssold",
    "/manager/coffeessold",
    "/manager/freecoffeesredeemed",
    "/manager/topcustomers",
    "/manager/topproducts",
    "/manager/orders",
    "/manager/refunds",
    "/manager/refunddetails"
  ]

  manager_routes.each do |route|
    describe "GET #{route}" do

      context "when logged in as a manager" do
        it "has a status code of 200 (OK)" do
          get route, {}, manager_session
          expect(last_response.status).to eq(200)
        end
      end

      context "when logged in as staff" do
        it "denies access and redirects (302)" do
          get route, {}, staff_session
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
end

RSpec.describe "Update Stock Test" do
  let(:manager_session) { { 'rack.session' => { user_id: 1, role: 'manager' } } }

end