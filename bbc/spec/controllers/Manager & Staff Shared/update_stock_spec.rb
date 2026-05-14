# frozen_string_literal: true

require_relative '../../spec_helper'

# =============================================================================
# Update Stock Tests
# =============================================================================

RSpec.describe 'Update Stock Tests' do
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'staff'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  test_cases = [
    {
      description: 'Valid inputs',
      params: {
        'product_id' => '1',
        'product_name' => 'Premium Roast',
        'product_stock' => '50',
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => '12.99',
        'product_image' => 'premium_roast.jpg',
        'product_description' => 'A rich and bold coffee.',
        'product_type' => 'Bean'
      }
    },
    {
      description: 'Invalid inputs - SQL Injection in description',
      params: {
        'product_id' => '1',
        'product_name' => 'Coffee',
        'product_stock' => '100',
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => '15.00',
        'product_image' => 'image.png',
        'product_description' => 'DROP TABLE products;--',
        'product_type' => 'Coffee'
      }
    },
    {
      description: 'Invalid inputs - HTML/Script Injection in description',
      params: {
        'product_id' => '1',
        'product_name' => 'Coffee',
        'product_stock' => '100',
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => '15.00',
        'product_image' => 'image.png',
        'product_description' => "<script>alert('XSS')</script>",
        'product_type' => 'Coffee'
      }
    },
    {
      description: 'Invalid Inputs - Non-numeric stock and price',
      params: {
        'product_id' => '1',
        'product_name' => 'Latte',
        'product_stock' => 'abc',
        'product_roast' => 'Dark',
        'product_origin' => 'Ethiopia',
        'product_price' => 'xyz',
        'product_image' => 'latte.jpg',
        'product_description' => 'Milky coffee',
        'product_type' => 'Coffee'
      }
    },
    {
      description: 'Invalid Inputs - All empty values',
      params: {
        'product_id' => '1',
        'product_name' => '',
        'product_stock' => '',
        'product_roast' => '',
        'product_origin' => '',
        'product_price' => '',
        'product_image' => '',
        'product_description' => '',
        'product_type' => ''
      }
    },
    {
      description: 'Invalid Inputs - Negative stock quantity',
      params: {
        'product_id' => '1',
        'product_name' => 'Espresso',
        'product_stock' => '-10',
        'product_roast' => 'Dark',
        'product_origin' => 'Italy',
        'product_price' => '8.99',
        'product_image' => 'espresso.jpg',
        'product_description' => 'Strong',
        'product_type' => 'Coffee'
      }
    },
    {
      description: 'Invalid Inputs - Zero or negative price',
      params: {
        'product_id' => '1',
        'product_name' => 'Espresso',
        'product_stock' => '10',
        'product_roast' => 'Dark',
        'product_origin' => 'Italy',
        'product_price' => '0',
        'product_image' => 'espresso.jpg',
        'product_description' => 'Strong',
        'product_type' => 'Coffee'
      }
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      it 'always redirects (302) to /managestock regardless of input validity' do
        post '/updatestock', test_case[:params], manager_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/managestock')
      end

      it 'is also processed when submitted by staff (302)' do
        post '/updatestock', test_case[:params], staff_session
        expect(last_response.status).to eq(302)
      end

      it 'redirects to the login page if not logged in' do
        post '/updatestock', test_case[:params], guest_session
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/login')
      end

      if test_case[:description].include?('Valid')
        it 'updates the product record in the database' do
          post '/updatestock', test_case[:params], manager_session
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

      if test_case[:description].include?('Invalid')
        it 'does not update the database and redirects with an error param' do
          product_id     = test_case[:params]['product_id'].to_i
          product_before = Products[product_id]
          post '/updatestock', test_case[:params], manager_session
          product_after = Products[product_id]
          expect(product_before).to eq(product_after)
          follow_redirect!
          expect(last_request.url).to include('error=')
        end
      end
    end
  end
end

# =============================================================================
# Update Stock Error Message Tests
# =============================================================================

RSpec.describe 'Update Stock Error Message Tests' do
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  test_cases = [
    {
      description: 'Invalid Product Name – nil value',
      params: {
        'product_id' => '1', 'product_name' => nil,
        'product_stock' => '100', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid product name.'
    },
    {
      description: 'Invalid Product Name – empty string',
      params: {
        'product_id' => '1', 'product_name' => '',
        'product_stock' => '100', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid product name.'
    },
    {
      description: 'Invalid Stock – non-numeric value',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => 'abc', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid stock quantity.'
    },
    {
      description: 'Invalid Stock – negative integer',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '-5', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid stock quantity.'
    },
    {
      description: 'Invalid Price – non-numeric value',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => 'abc',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid price.'
    },
    {
      description: 'Invalid Price – zero value',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '0',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid price.'
    },
    {
      description: 'Invalid Roast – nil value',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '15.00',
        'product_roast' => nil, 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid roast.'
    },
    {
      description: 'Invalid Origin – contains illegal characters',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia"/n',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid origin.'
    },
    {
      description: 'Invalid Image – contains a double-quote character',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image".png', 'product_description' => 'Description',
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid image URL.'
    },
    {
      description: 'Invalid Description – nil value',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => nil,
        'product_type' => 'Coffee'
      },
      expected_error: 'Please enter a valid description.'
    },
    {
      description: 'Invalid Type – unrecognised type string',
      params: {
        'product_id' => '1', 'product_name' => 'Name',
        'product_stock' => '10', 'product_price' => '15.00',
        'product_roast' => 'Dark', 'product_origin' => 'Ethiopia',
        'product_image' => 'image.png', 'product_description' => 'Description',
        'product_type' => 'Widget'
      },
      expected_error: 'Please enter a valid product type (Bean or Coffee).'
    }
  ]

  test_cases.each do |test_case|
    context "When #{test_case[:description]}" do
      it 'redirects to /managestock and shows the appropriate error message' do
        post '/updatestock', test_case[:params], manager_session
        follow_redirect!
        expect(last_response.body).to include(test_case[:expected_error])
      end
    end
  end
end
