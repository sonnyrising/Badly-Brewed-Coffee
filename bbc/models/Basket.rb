# frozen_string_literal: true

class Basket < Sequel::Model(:Basket)
  def addBeanToBasket(params)
    self.UserId = params.fetch('userId', '').strip
    self.ProductId = params.fetch('productId', '').strip
    self.TransactionId = nil
    self.ItemId = rand(10000000)
    self.Quantity = params.fetch('quantity', '').strip
    self.Milk = nil
    self.Size = nil

  end

  def addCoffeeToBasket(params)
    self.UserId = params.fetch('userId', '').strip
    self.ProductId = params.fetch('productId', '').strip
    self.TransactionId = nil
    self.ItemId = rand(10000000)
    self.Quantity = params.fetch('quantity', '').strip
    self.Milk = params.fetch('milk', '').strip
    self.Size = params.fetch('size','').strip
  end

  def self.getItemId(params)
    product = params[:ProductId] || params['productId']
    Basket.where(ProductId: product).get(:ItemId)
  end

  def productExists(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    Basket.where(UserId: user, ProductId: product).last
  end

  def self.clearGuestBasket
    Basket.where(UserId: 1).destroy
  end

  def userCheck(params)
    user = params.fetch('userId', '')
    Basket.where(UserId: user).last
  end

  def productCheck(params)
    product = params.fetch('productId', '')
    Basket.where(ProductId: product).last
  end

  def bought(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    item = Basket.where(UserId: user, ProductId: product).last

    return if item.nil?

    item unless item.TransactionId.nil?
  end

  def checkLatest(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    latest = Basket.where(UserId: user, ProductId: product).last
    nil if latest.TransactionId.nil?
  end

  def updateQuantity(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    quantity_p = Basket.where(UserId: user, ProductId: product).last
    additional_q = params.fetch('quantity', '').to_i

    if (quantity_p.Quantity + additional_q) >= 10
      Basket.where(UserId: user, ProductId: product).update(Quantity: 10)
    else
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + additional_q)
    end
  end

  def self.numOfProductsInBasket(userId)
    count = 0
    Basket.each do |product|
      count += product.Quantity if product.TransactionId.nil? && (product.UserId == userId)
    end

    count
  end

  def self.getProductNamesForUser(userId)
    names = []
    Basket.each do |b_product|
      next unless b_product.UserId == userId && b_product.TransactionId.nil?

      Products.each do |product|
        if product.ProductId == b_product.ProductId
          names << product
          break
        end
      end
    end

    names
  end

  def self.RemoveItem(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')
    basket_item = Basket.where(UserId: user, ProductId: product)
    basket_item.destroy
  end

  def self.getQuantityForUser(userId)
    quantities = []
    Basket.each do |b_product|
      quantities << b_product if b_product.UserId == userId
    end
    quantities
  end

  def self.add(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    quantity_p = Basket.where(UserId: user, ProductId: product).last

    return unless quantity_p.Quantity < 10

    Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + 1)
  end

  def self.subtract(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')

    quantity_p = Basket.where(UserId: user, ProductId: product).last

    if quantity_p.Quantity > 1
      Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity - 1)
    else
      quantity_p.destroy
    end
  end

  def self.finishedTransaction(productId, userId)
    product = Basket.where(UserId: userId, ProductId: productId).last

    return true if product.TransactionId.nil?


    false
  end

  def self.orderPlaced(userId, transactionId)
    Basket.where(UserId: userId, TransactionId: nil).update(TransactionId: transactionId)
  end

  def self.addCoffees(params)
    user = params.fetch('userId', '')
    product = params.fetch('productId', '')
    params.fetch('milkType', '')
    params.fetch('coffeeSize', '')

    quantity_p = Basket.where(UserId: user, ProductId: product).last

    return unless quantity_p.Quantity < 10

    Basket.where(UserId: user, ProductId: product).update(Quantity: quantity_p.Quantity + 1)
  end
end
