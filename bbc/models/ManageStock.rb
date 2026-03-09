require 'sequel'
require 'sqlite3'
require_relative '../db/db'

class ManageStock

  ##Update All
  def self.update_product(productId, productName, price, stockQuantity)
    Products.where(ProductId: productId).update(
      ProductName: productName,
      Price: price,
      StockQuantity: stockQuantity)
  end
end

