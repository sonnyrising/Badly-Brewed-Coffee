class Basket < Sequel::Model(:Basket)

  def addToBasket(params)
    self.UserId = params.fetch("userId","").strip
    self.ProductId = params.fetch("productId","").strip
    self.TransactionId = nil
    self.Quantity = params.fetch("quantity","").strip
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
    additional_q = params.fetch("quantity","").to_i
    
    if (quantity_p.Quantity + additional_q) >= 10
      Basket.where(UserId: user, ProductId: product).update(Quantity: 10)
    else
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + additional_q )
    end
  end

  def self.numOfProductsInBasket(userId)
    count = 0
    Basket.each do |product|
      if (product.TransactionId).nil?
        count += product.Quantity if product.UserId == userId
      end
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

  def self.add(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")
    
    quantity_p = Basket.where(UserId: user, ProductId: product).first

    if quantity_p.Quantity < 10
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + 1)  
    end
  end

  def self.subtract(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")
    
    quantity_p = Basket.where(UserId: user, ProductId: product).first

    if quantity_p.Quantity > 1
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity - 1)
    else
      quantity_p.destroy
    end
  end

  def self.finishedTransaction(productId, userId)
    product = Basket.where(UserId: userId, ProductId: productId).first
    
    if (product.TransactionId).nil?
      return true
    else
      return false
    end
  end

  def self.orderPlaced(userId, transactionId)
    Basket.where(UserId: userId, TransactionId: nil).update(TransactionId: transactionId)
  end

  def self.addCoffees(params)
    user = params.fetch("userId", "")
    product = params.fetch("productId", "")
    milkType = params.fetch("milkType", "")
    coffeeSize = params.fetch("coffeeSize", "")
    
    quantity_p = Basket.where(UserId: user, ProductId: product).first

    if quantity_p.Quantity < 10
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + 1)  
    end
  end
end