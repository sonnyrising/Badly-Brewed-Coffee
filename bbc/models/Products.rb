# frozen_string_literal: true

require 'sequel'
require 'sqlite3'
require_relative '../db/db'

class Products < Sequel::Model(:Products)
  # Product Name
  def self.GetProductName(productId)
    Products.where(ProductId: productId).get(:ProductName)
  end

  def self.SetProductName(productId, productName)
    Products.where(ProductId: productId).update(ProductName: productName)
  end

  # Product Price
  def self.GetPrice(productId)
    Products.where(ProductId: productId).get(:Price)
  end

  def self.SetPrice(productId, productPrice)
    Products.where(ProductId: productId).update(Price: productPrice)
  end

  # Product Quantity
  def self.GetStockQuantity(productId)
    Products.where(ProductId: productId).get(:StockQuantity)
  end

  def self.SetStockQuantity(productId, stockQuantity)
    Products.where(ProductId: productId).update(StockQuantity: stockQuantity)
  end

  # Product Image
  def self.GetProductImage(productId)
    Products.where(ProductId: productId).get(:ProductImage)
  end

  def self.SetProductImage(productId, productImage)
    Products.where(ProductId: productId).update(ProductImage: productImage)
  end

  # Product Description
  def self.GetProductDescription(productId)
    Products.where(ProductId: productId).get(:ProductDescription)
  end

  def self.SetProductDescription(productId, productDescription)
    Products.where(ProductId: productId).update(ProductDescription: productDescription)
  end

  # Update All
  def self.update_product(productId, productName, price, stockQuantity, description, origin, roast, image, type)
    bean = type == 'Bean'

    Products.where(ProductId: productId).update(
      ProductName: productName,
      Price: price,
      StockQuantity: stockQuantity,
      ProductDescription: description,
      Origin: origin,
      Roast: roast,
      ProductImage: image,
      Bean: bean
    )
  end

  def self.coffeeOrBeans(params)
    productId = params[:productId]

    Products.where(ProductId: productId).get(:Bean)
  end

end
