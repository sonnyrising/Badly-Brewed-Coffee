require_relative '../spec_helper'

# =============================================================================
# Shared route authentication
# =============================================================================

RSpec.describe "Manager/Staff Shared Route Authentication Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  manager_staff_shared_routes = [
    "/managestock",
    "/addproduct",
    "/orders",
    "/refunds",
    "/refunddetails"
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


# =============================================================================
# Update Stock Tests
# =============================================================================

RSpec.describe "Update Stock Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  test_cases = [
    {
      description: "Valid inputs",
      params: {
        'product_id'          => "1",
        'product_name'        => "Premium Roast",
        'product_stock'       => "50",
        'product_roast'       => "Dark",
        'product_origin'      => "Ethiopia",
        'product_price'       => "12.99",
        'product_image'       => "premium_roast.jpg",
        'product_description' => "A rich and bold coffee.",
        'product_type'        => "Bean"
      }
    },
    {
      description: "Invalid inputs - SQL Injection in description",
      params: {
        'product_id'          => "1",
        'product_name'        => "Coffee",
        'product_stock'       => "100",
        'product_roast'       => "Dark",
        'product_origin'      => "Ethiopia",
        'product_price'       => "15.00",
        'product_image'       => "image.png",
        'product_description' => "DROP TABLE products;--",
        'product_type'        => "Coffee"
      }
    },
    {
      description: "Invalid inputs - HTML/Script Injection in description",
      params: {
        'product_id'          => "1",
        'product_name'        => "Coffee",
        'product_stock'       => "100",
        'product_roast'       => "Dark",
        'product_origin'      => "Ethiopia",
        'product_price'       => "15.00",
        'product_image'       => "image.png",
        'product_description' => "<script>alert('XSS')</script>",
        'product_type'        => "Coffee"
      }
    },
    {
      description: "Invalid Inputs - Non-numeric stock and price",
      params: {
        'product_id'          => "1",
        'product_name'        => "Latte",
        'product_stock'       => "abc",
        'product_roast'       => "Dark",
        'product_origin'      => "Ethiopia",
        'product_price'       => "xyz",
        'product_image'       => "latte.jpg",
        'product_description' => "Milky coffee",
        'product_type'        => "Coffee"
      }
    },
    {
      description: "Invalid Inputs - All empty values",
      params: {
        'product_id'          => "1",
        'product_name'        => "",
        'product_stock'       => "",
        'product_roast'       => "",
        'product_origin'      => "",
        'product_price'       => "",
        'product_image'       => "",
        'product_description' => "",
        'product_type'        => ""
      }
    },
    {
      description: "Invalid Inputs - Negative stock quantity",
      params: {
        'product_id'          => "1",
        'product_name'        => "Espresso",
        'product_stock'       => "-10",
        'product_roast'       => "Dark",
        'product_origin'      => "Italy",
        'product_price'       => "8.99",
        'product_image'       => "espresso.jpg",
        'product_description' => "Strong",
        'product_type'        => "Coffee"
      }
    },
    {
      description: "Invalid Inputs - Zero or negative price",
      params: {
        'product_id'          => "1",
        'product_name'        => "Espresso",
        'product_stock'       => "10",
        'product_roast'       => "Dark",
        'product_origin'      => "Italy",
        'product_price'       => "0",
        'product_image'       => "espresso.jpg",
        'product_description' => "Strong",
        'product_type'        => "Coffee"
      }
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do

      it "always redirects (302) to /managestock regardless of input validity" do
        post "/updatestock", test_case[:params], manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/managestock")
      end

      it "is also processed when submitted by staff (302)" do
        post "/updatestock", test_case[:params], staff_session
        expect(last_response.status).to eq(302)
      end

      it "redirects to the login page if not logged in" do
        post "/updatestock", test_case[:params], guest_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/login")
      end

      if test_case[:description].include?("Valid")
        it "updates the product record in the database" do
          post "/updatestock", test_case[:params], manager_session
          product_id      = test_case[:params]['product_id'].to_i
          updated_product = Products[product_id]
          expect(updated_product[:ProductName]).to       eq(test_case[:params]['product_name'])
          expect(updated_product[:StockQuantity]).to     eq(test_case[:params]['product_stock'].to_i)
          expect(updated_product[:Roast]).to             eq(test_case[:params]['product_roast'])
          expect(updated_product[:Origin]).to            eq(test_case[:params]['product_origin'])
          expect(updated_product[:Price]).to             eq(test_case[:params]['product_price'].to_f)
          expect(updated_product[:ProductImage]).to      eq(test_case[:params]['product_image'])
          expect(updated_product[:ProductDescription]).to eq(test_case[:params]['product_description'])
        end
      end

      if test_case[:description].include?("Invalid")
        it "does not update the database and redirects with an error param" do
          product_id     = test_case[:params]['product_id'].to_i
          product_before = Products[product_id]
          post "/updatestock", test_case[:params], manager_session
          product_after  = Products[product_id]
          expect(product_before).to eq(product_after)
          follow_redirect!
          expect(last_request.url).to include("error=")
        end
      end
    end
  end
end


# =============================================================================
# Update Stock Error Message Tests
# =============================================================================

RSpec.describe "Update Stock Error Message Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  test_cases = [
    {
      description: "Invalid Product Name – nil value",
      params: {
        'product_id' => "1", 'product_name' => nil,
        'product_stock' => "100", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid product name."
    },
    {
      description: "Invalid Product Name – empty string",
      params: {
        'product_id' => "1", 'product_name' => "",
        'product_stock' => "100", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid product name."
    },
    {
      description: "Invalid Stock – non-numeric value",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "abc", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid stock quantity."
    },
    {
      description: "Invalid Stock – negative integer",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "-5", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid stock quantity."
    },
    {
      description: "Invalid Price – non-numeric value",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "abc",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid price."
    },
    {
      description: "Invalid Price – zero value",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "0",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid price."
    },
    {
      description: "Invalid Roast – nil value",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "15.00",
        'product_roast' => nil, 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid roast."
    },
    {
      description: "Invalid Origin – contains illegal characters",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia\"/n",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid origin."
    },
    {
      description: "Invalid Image – contains a double-quote character",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image\".png", 'product_description' => "Description",
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid image URL."
    },
    {
      description: "Invalid Description – nil value",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => nil,
        'product_type' => "Coffee"
      },
      expected_error: "Please enter a valid description."
    },
    {
      description: "Invalid Type – unrecognised type string",
      params: {
        'product_id' => "1", 'product_name' => "Name",
        'product_stock' => "10", 'product_price' => "15.00",
        'product_roast' => "Dark", 'product_origin' => "Ethiopia",
        'product_image' => "image.png", 'product_description' => "Description",
        'product_type' => "Widget"
      },
      expected_error: "Please enter a valid product type (Bean or Coffee)."
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      it "redirects to /managestock and shows the appropriate error message" do
        post "/updatestock", test_case[:params], manager_session
        follow_redirect!
        expect(last_response.body).to include(test_case[:expected_error])
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

# =============================================================================
# Managestock Page and Alerts
# =============================================================================

RSpec.describe "Manage Stock Page Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  describe "page content" do
    it "lists all seeded products by name" do
      get "/managestock", {}, manager_session
      expect(last_response.body).to include("Old Coffee")
      expect(last_response.body).to include("Spare Blend")
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