require_relative '../spec_helper'

RSpec.describe "Authentication Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff' } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil } } }

  manager_staff_shared_routes = [
    "/managestock",
    "/addproduct",
    "/orders",
    "/refunds",
    "/refunddetails",
    "/managestock"
  ]

  manager_staff_shared_routes.each do |route|
    describe "GET #{route}" do

      context "when logged in as a manager" do
        it "has a status code of 200 (OK)" do
          get route, {}, manager_session
          expect(last_response.status).to eq(200)
        end
      end

      context "when logged in as staff" do
        it "has a status code of 200 (OK)" do
          get route, {}, staff_session
          expect(last_response.status).to eq(200)
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

RSpec.describe "Update Stock Test: " do
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  test_cases = [
    {
      description: "Valid inputs",
      params: {
        'product_id'=> 1,
        'product_name' => "Premium Roast",
        'product_stock' => "50",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
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
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
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
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
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
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
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
        'product_roast' => '',
        'product_origin' => '',
        'product_price' => "",
        'product_image' => "",
        'product_description' => ""
      }
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      it "processes the input and redirects to /managestock" do
        post "/updatestock", test_case[:params], manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/managestock")
      end

      if test_case[:description].include?("Valid")
        it "modifies the db and returns a success message if the inputs are valid" do
          post "/updatestock", test_case[:params], manager_session
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
          post "/updatestock", test_case[:params], manager_session
          product_after = Products[product_id]

          expect(product_before).to eq(product_after)
          follow_redirect!
          expect(last_request.url).to include("error=")
        end
      end
    end
  end
end

RSpec.describe "Update Stock Error Tests" do
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  test_cases = [
    {
      description: "Invalid Product Name",
      params: {
        'product_id' => "1",
        'product_name' => nil,
        'product_stock' => "100",
        'product_price' => "15.00",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_image' => "image.png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Stock",
      params: {
        'product_id' => "1",
        'product_name' => "Name",
        'product_stock' => "a",
        'product_price' => "15.00",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_image' => "image.png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Roast",
      params: {
        'product_id' => "1",
        'product_name' => "Name",
        'product_stock' => "10",
        'product_roast' => nil,
        'product_origin' => 'Ethiopian',
        'product_price' => "15.00",
        'product_image' => "image.png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Origin",
      params: {
        'product_id' => "1",
        'product_name' => "Name",
        'product_stock' => "10",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia"/n',
        'product_price' => "15.00",
        'product_image' => "image.png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Price",
      params: {
        'product_id' => "1",
        'product_name' => "Name",
        'product_stock' => "100",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => "b",
        'product_image' => "image.png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Image",
      params: {
        'product_id' => "1",
        'product_name' => "name",
        'product_stock' => "100",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => "15.00",
        'product_image' => "image\".png",
        'product_description' => "Description"
      }
    },
    {
      description: "Invalid Description",
      params: {
        'product_id' => "1",
        'product_name' => "name",
        'product_stock' => "100",
        'product_price' => "15.00",
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_image' => "image.png",
        'product_description' => nil
      }
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      if test_case[:description].include?("Invalid")
        it "returns the appropriate error message" do
          post "/updatestock", test_case[:params], manager_session
          follow_redirect!
          desc = test_case[:description].downcase

          if desc.include?("name")
            expect(last_response.body).to include("Please enter a valid product name.")
          elsif desc.include?("stock")
            expect(last_response.body).to include("Please enter a valid stock quantity.")
          elsif desc.include?("price")
            expect(last_response.body).to include("Please enter a valid price.")
          elsif desc.include?("image")
            expect(last_response.body).to include("Please enter a valid image URL.")
          elsif desc.include?("html injection")
            expect(last_response.body).to include("Please enter a valid description.")
          end
        end
      end
    end
  end
end