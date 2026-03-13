class Basket < Sequel::Model(:Basket)

  def addToBasket(params)
    self.UserId = params.fetch("userId","").strip
    self.ProductId = params.fetch("productId","").strip
    self.Quantity = params.fetch("quantity","").strip
    self.OrderStatus = "null"
  end
  
end