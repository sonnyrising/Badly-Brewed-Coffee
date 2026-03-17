require 'sequel'
require 'sqlite3'
require_relative '../db/db'

class Products < Sequel::Model(:Products)
  # Product Name
  def self.GetProductName(productId)
    return Products.where(ProductId: productId).get(:ProductName)
  end

  def self.SetProductName(productId, productName)
    Products.where(ProductId: productId).update(ProductName: productName)
  end

  # Product Price
  def self.GetPrice(productId)
    return Products.where(ProductId: productId).get(:Price)
  end

  def self.SetPrice(productId, productPrice)
    Products.where(ProductId: productId).update(Price: productPrice)
  end

  # Product Quantity
  def self.GetStockQuantity(productId)
    return Products.where(ProductId: productId).get(:StockQuantity)
  end

  def self.SetStockQuantity(productId, stockQuantity)
    Products.where(ProductId: productId).update(StockQuantity: stockQuantity)
  end

  # Product Image
  def self.GetProductImage(productId)
    return Products.where(ProductId: productId).get(:ProductImage)
  end

  def self.SetProductImage(productId, productImage)
    Products.where(ProductId: productId).update(ProductImage: productImage)
  end


  # Update All
  def self.update_product(productId, productName, price, stockQuantity)
    Products.where(ProductId: productId).update(
      ProductName: productName,
      Price: price,
      StockQuantity: stockQuantity
    )
  end
end