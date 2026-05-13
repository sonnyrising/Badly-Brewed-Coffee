require_relative '../../spec_helper'

# =============================================================================
# Managestock Page and Alerts
# =============================================================================

RSpec.describe "Manage Stock Page Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  describe "page content" do
    it "lists all seeded products by name" do
      get "/managestock", {}, manager_session
      expect(last_response.body).to include("Old Coffee")
      expect(last_response.body).to include("Blend")
    end

    it "includes a Save Changes button for each product" do
      get "/managestock", {}, manager_session
      expect(last_response.body).to include("Save Changes")
    end

    it "includes a Delete Product button for each product" do
      get "/managestock", {}, manager_session
      expect(last_response.body).to include("Delete Product")
    end

    it "includes the Add Product (+) link" do
      get "/managestock", {}, manager_session
      expect(last_response.body).to include("/addproduct")
    end
  end

  error_banner_cases = [
    { param: "invalid_name", message: "Please enter a valid product name."},
    { param: "invalid_stock", message: "Please enter a valid stock quantity."},
    { param: "invalid_price", message: "Please enter a valid price."},
    { param: "invalid_image", message: "Please enter a valid image URL."},
    { param: "invalid_description", message: "Please enter a valid description."},
    { param: "invalid_origin", message: "Please enter a valid origin."},
    { param: "invalid_roast", message: "Please enter a valid roast."},
    { param: "invalid_type", message: "Please enter a valid product type (Bean or Coffee)."}
  ]

  describe "error banners from ?error= param" do
    error_banner_cases.each do |error_case|
      context "when error=#{error_case[:param]}" do
        it "displays '#{error_case[:message]}'" do
          get "/managestock?error=#{error_case[:param]}", {}, manager_session
          expect(last_response.body).to include(error_case[:message])
        end
      end
    end

    context "when no error param is present" do
      it "does not render the alert-banner div" do
        get "/managestock", {}, manager_session
        expect(last_response.body).to_not include('id="alert-banner"')
      end
    end

    context "when an unrecognised error param is passed" do
      it "returns 200 and does not render the alert-banner div" do
        get "/managestock?error=unknown_error", {}, manager_session
        expect(last_response.status).to eq(200)
        expect(last_response.body).to_not include('id="alert-banner"')
      end
    end
  end
end

# =============================================================================
# Delete Product Tests
# =============================================================================

RSpec.describe "Delete Product Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  test_cases = [
    {
      description: "Valid Product ID – product exists",
      params: { 'product_id' => "1" }
    },
    {
      description: "Non-existent Product ID",
      params: { 'product_id' => "999" }
    },
    {
      description: "Invalid Product ID – non-numeric string",
      params: { 'product_id' => "abc" }
    }
  ]

  context "When the item to be deleted exists" do
    it "removes the product from the database" do
      post "/deleteproduct", test_cases[0][:params], manager_session
      expect(Products.where(ProductId: 1).count).to eq(0)
    end

    it "redirects to /managestock after deletion" do
      post "/deleteproduct", test_cases[0][:params], manager_session
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/managestock")
    end

    it "it also deletes when submitted by a staff user" do
      post "/deleteproduct", test_cases[0][:params], staff_session
      expect(last_response.status).to eq(302)
      expect(Products.where(ProductId: 1).count).to eq(0)
    end

    it "redirects to the login page if not logged in" do
      post "/deleteproduct", test_cases[0][:params], guest_session
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/login")
    end
  end

  context "When the product_id does not exist in the database" do
    it "prints an error to stdout and does not crash" do
      expect {
        post "/deleteproduct", test_cases[1][:params], manager_session
      }.to output(/Error: Invalid product ID:/).to_stdout
    end

    it "still redirects to /managestock" do
      post "/deleteproduct", test_cases[1][:params], manager_session
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/managestock")
    end
  end

  context "When the product_id is not a number" do
    it "prints an error to the terminal" do
      expect {
        post "/deleteproduct", test_cases[2][:params], manager_session
      }.to output(/Error: Invalid product ID:/).to_stdout
    end

    it "still redirects to /managestock" do
      post "/deleteproduct", test_cases[2][:params], manager_session
      expect(last_response.status).to eq(302)
      expect(last_response.location).to include("/managestock")
    end

    it "does not remove any products from the database" do
      count_before = Products.count
      post "/deleteproduct", test_cases[2][:params], manager_session
      expect(Products.count).to eq(count_before)
    end
  end
end


# =============================================================================
# Add Product Tests
# =============================================================================

RSpec.describe "Add Product Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  describe "GET /addproduct" do
    context "when logged in as a manager" do
      it "returns 200 and renders the product form" do
        get "/addproduct", {}, manager_session
        expect(last_response.status).to eq(200)
      end

      it "renders all required form input fields" do
        get "/addproduct", {}, manager_session
        %w[product_name product_stock product_price
           product_roast product_origin product_description product_image].each do |field|
          expect(last_response.body).to include(field)
        end
      end
    end

    context "when logged in as staff" do
      it "returns 200" do
        get "/addproduct", {}, staff_session
        expect(last_response.status).to eq(200)
      end
    end

    context "when not logged in" do
      it "redirects (302)" do
        get "/addproduct", {}, guest_session
        expect(last_response.status).to eq(302)
      end
    end
  end

  describe "POST /addproduct" do
    valid_params = {
      'product_name'        => "Premium Roast",
      'product_stock'       => "50",
      'product_roast'       => "Dark",
      'product_origin'      => "Ethiopia",
      'product_price'       => "12.99",
      'product_image'       => "premium_roast.jpg",
      'product_description' => "A rich and bold coffee.",
      'product_type'        => "Bean"
    }

    context "When valid inputs are submitted" do
      it "redirects to /managestock" do
        post "/addproduct", valid_params, manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/managestock")
      end

      it "inserts a new product into the database" do
        count_before = Products.count
        post "/addproduct", valid_params, manager_session
        expect(Products.count).to eq(count_before + 1)
      end
    end

    context "When valid inputs are submitted by staff" do
      it "redirects to /managestock" do
        post "/addproduct", valid_params, staff_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/managestock")
      end
    end

    invalid_cases = [
      {
        description: "blank product name",
        params: valid_params.merge('product_name' => "")
      },
      {
        description: "non-numeric stock",
        params: valid_params.merge('product_stock' => "lots")
      },
      {
        description: "zero price",
        params: valid_params.merge('product_price' => "0")
      },
      {
        description: "all fields nil",
        params: {
          'product_name' => nil, 'product_stock' => nil,
          'product_roast' => nil, 'product_origin' => nil,
          'product_price' => nil, 'product_image' => nil,
          'product_description' => nil, 'product_type' => nil
        }
      }
    ]

    invalid_cases.each do |test_case|
      context "When #{test_case[:description]}" do
        it "redirects to /managestock with an error param" do
          post "/addproduct", test_case[:params], manager_session
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_request.url).to include("error=")
        end

        it "does not add a new record to the database" do
          count_before = Products.count
          post "/addproduct", test_case[:params], manager_session
          expect(Products.count).to eq(count_before)
        end
      end
    end
  end
end