# frozen_string_literal: true

require_relative '../spec_helper'

#========== Products Model Tests ==========#
RSpec.describe 'Products Management,' do

#Product Name -------------------------------------------#
  context ".GetProductName(productId)" do
    it "retrieves product name for the given product ID" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductName: 'Coffee Test')

      name = Products.GetProductName(target_product)
      expect(name).to eq('Coffee Test')
    end

    it "returns nil if product entry doesn't exist" do
      name = Products.GetProductName(999)
      expect(name).to be_nil
    end
  end

  context ".SetProductName(productId, productName)" do
    it "updates the product entry's name" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductName: 'Coffee Test')

      name = Products.SetProductName(target_product, 'New Coffee')
      updated_product = Products.first(ProductId: 1)
      expect(updated_product[:ProductName]).to eq('New Coffee')
    end
  end

#Product Price -------------------------------------------#
  context ".GetPrice(productId)" do
    it "retrieves product price for the given product ID" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, Price: 10.50)

      price = Products.GetPrice(target_product)
      expect(price).to eq(10.50)
    end

    it "returns nil if product entry doesn't exist" do
      price = Products.GetPrice(999)
      expect(price).to be_nil
    end
  end

  context ".SetPrice(productId, productPrice)" do
    it "updates the product entry's price" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, Price: 10.50)

      price = Products.SetPrice(target_product, 25.50)
      updated_product = Products.first(ProductId: 1)
      expect(updated_product[:Price]).to eq(25.50)
    end
  end

#Product Quantity -------------------------------------------#
  context ".GetStockQuantity(productId)" do
    it "retrieves product stock/quantity for the given product ID" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, StockQuantity: 10)

      stock = Products.GetStockQuantity(target_product)
      expect(stock).to eq(10)
    end

    it "returns nil if product entry doesn't exist" do
      stock = Products.GetStockQuantity(999)
      expect(stock).to be_nil
    end
  end

  context ".SetStockQuantity(productId, stockQuantity)" do
    it "updates the product entry's stock" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, StockQuantity: 10)

      stock = Products.SetStockQuantity(target_product, 5)
      updated_product = Products.first(ProductId: 1)
      expect(updated_product[:StockQuantity]).to eq(5)    
    end
  end

#Product Image -------------------------------------------#
  context ".GetProductImage(productId)" do
    it "retrieves product image for the given product ID" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductImage: 'test_image.png')

      image = Products.GetProductImage(target_product)
      expect(image).to eq('test_image.png')
    end

    it "returns nil if product entry doesn't exist" do
      image = Products.GetProductImage(999)
      expect(image).to be_nil
    end
  end

  context ".SetProductImage(productId, productImage)" do
    it "updates the product entry's image" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductImage: 'test_image.png')

      image = Products.SetProductImage(target_product, 'new_image.png')
      updated_product = Products.first(ProductId: 1)
      expect(updated_product[:ProductImage]).to eq('new_image.png')
    end
  end

#Product Description -------------------------------------------#
  context ".GetProductDescription(productId)" do
    it "retrieves product description for the given product ID" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductDescription: 'test description')

      description = Products.GetProductDescription(target_product)
      expect(description).to eq('test description')
    end

    it "returns nil if product entry doesn't exist" do
      description = Products.GetProductDescription(999)
      expect(description).to be_nil
    end
  end

  context ".SetProductDescription(productId, productDescription)" do
    it "updates the product entry's description" do
      Products.dataset.delete
      target_product = Products.insert(ProductId: 1, ProductDescription: 'test description')

      description = Products.SetProductDescription(target_product, 'new description')
      updated_product = Products.first(ProductId: 1)
      expect(updated_product[:ProductDescription]).to eq('new description')
    end
  end

#Update All -------------------------------------------#
  context ".update_product" do
    it "successfully updates all fields of an existing product entry" do
      Products.dataset.delete
      Products.insert(
        ProductId: 1,
        ProductName: 'test name',
        Price: 10.50,
        StockQuantity: 5,
        ProductDescription: 'test description',
        Origin: 'test origin',
        Roast: 'test roast',
        ProductImage: 'test_image.png',
        Bean: false
      )

      Products.update_product(
        1,
        'new name',
        5.50,
        10,
        'new description',
        'new origin',
        'new roast',
        'new_image.png',
        'Bean'
      )

      updated_product = Products.first(ProductId: 1)

      expect(updated_product[:ProductName]).to eq('new name')
      expect(updated_product[:Price]).to eq(5.50)
      expect(updated_product[:StockQuantity]).to eq(10)
      expect(updated_product[:ProductDescription]).to eq('new description')
      expect(updated_product[:Origin]).to eq('new origin')
      expect(updated_product[:Roast]).to eq('new roast')
      expect(updated_product[:ProductImage]).to eq('new_image.png')
      expect(updated_product[:Bean]).to be_truthy
    end
  end

#Determines Coffee or Beans -------------------------------------------#
  context ".coffeeOrBeans(params)" do
    it "returns false if product isn't classified as Bean" do
      Products.dataset.delete
      Products.insert(ProductId: 1, Bean: false)
      params = { 'productId' => '1' }

      result = Products.coffeeOrBeans(params)
      expect(result).to be_falsy
    end

    it "returns true if product is classified as Bean" do
      Products.dataset.delete
      Products.insert(ProductId: 1, Bean: true)
      params = {  productId: 1  }

      result = Products.coffeeOrBeans(params)
      expect(result).to be_truthy
    end

    it "returns nil if product entry doesn't exist" do
      params = {  'productId' =>  '999' }
      result = Products.coffeeOrBeans(params)
      expect(result).to be_nil
    end
  end
end









