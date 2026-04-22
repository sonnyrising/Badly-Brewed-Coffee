require_relative '../spec_helper'

RSpec.describe "Authentication Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff' } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil } } }

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
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  test_cases = [
    {
      description: "Valid inputs",
      params: {
        'product_id'=> 1,
        'product_name' => "Premium Roast",
        'product_stock' => "50",
        'product_price' => "12.99",
        'product_image' => "premium_roast.jpg",
        'product_description' => "A rich and bold coffee."
      }
    },
    {
      description: "Invalid inputs - SQL Injection",
      params: {
        'product_id' => "1",
        'product_name' => "Coffee",
        'product_stock' => "100",
        'product_price' => "15.00",
        'product_image' => "image.png",
        'product_description' => "DROP TABLE products;--"
      }
    },
    {
      description: "Invalid inputs - HTML Injection",
      params: {
        'product_id' => "1",
        'product_name' => "Coffee",
        'product_stock' => "100",
        'product_price' => "15.00",
        'product_image' => "image.png",
        'product_description' => "Descrption: <script>alert('XSS')</script>"
      }
    },{
      description: "Invalid Inputs - Non-numeric values",
      params: {
        'product_id' => "1",
        'product_name' => "Latte",
        'product_stock' => "abc",
        'product_price' => "xyz",
        'product_image' => "latte.jpg",
        'product_description' => "Milky coffee"
      }
    },
    {
      description: "Invalid Inputs - Empty values",
      params: {
        'product_id' => "1",
        'product_name' => "",
        'product_stock' => "",
        'product_price' => "",
        'product_image' => "",
        'product_description' => ""
      }
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      it "processes the input and redirects to /manager/managestock" do
        post "/manager/updatestock", test_case[:params], manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/manager/managestock")
      end

      if test_case[:description].include?("Valid")
        it "modifies the db and returns a success message if the inputs are valid" do
          post "/manager/updatestock", test_case[:params], manager_session
          product_id = test_case[:params]['product_id'].to_i
          updated_product = Products[product_id]
          expect(updated_product.ProductName).to eq(test_case[:params]['product_name'])
          expect(updated_product.StockQuantity).to eq(test_case[:params]['product_stock'].to_i)
        end
      end

      if test_case[:description].include?("Invalid")
        it "returns an error message and doesn't update the db if the inputs aren't valid" do
          product_id = test_case[:params]['product_id'].to_i
          product_before = Products[product_id]
          post "/manager/updatestock", test_case[:params], manager_session
          product_after = Products[product_id]

          expect(product_before).to eq(product_after)
          follow_redirect!
          expect(last_request.url).to include("error=")
        end
      end
    end
  end
end