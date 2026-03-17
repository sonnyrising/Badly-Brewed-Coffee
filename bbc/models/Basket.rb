class Basket < Sequel::Model(:Basket)

  def addToBasket(params)
    self.UserId = params.fetch("userId","").strip
    self.ProductId = params.fetch("productId","").strip
    self.Quantity = params.fetch("quantity","").strip
    self.OrderStatus = "null"
  end

  def productExists(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")

    return Basket.where(UserId: user, ProductId: product).first
  end

  def userCheck(params)
    user = params.fetch("userId", "")
    return Basket.where(UserId: user).first
  end

  def productCheck(params)
    product = params.fetch("productId", "")
    return Basket.where(ProductId: product).first
  end

  def updateQuantity(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")

    quantity_p = Basket.where(UserId: user, ProductId: product).first
    Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + (params.fetch("quantity", "")).to_i )
  end

  def self.numOfProductsInBasket(userId)
    count = 0
    Basket.each do |product|
      count += product.Quantity if product.UserId == userId
    end

    return count
  end

  def self.getProductNamesForUser(userId)
    names = Array.new
    Basket.each do |b_product|
      if b_product.UserId == userId
        Products.each do |product|
          if product.ProductId == b_product.ProductId
            names << product
            break
          end
        end
      end
    end

    return names
  end

  def self.RemoveItem(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")
    basket_item = Basket.where(UserId: user, ProductId: product)
    basket_item.destroy
  end
  
  def self.getQuantityForUser(userId)
    quantities = Array.new
    Basket.each do |b_product|
      if b_product.UserId == userId
        quantities << b_product
      end
    end
    return quantities
  end

  def clearBasket(userId)
    Basket.where(UserId: userId).delete
  end
  
end