class Basket < Sequel::Model(:Basket)

  def addToBasket(params)
    self.UserId = params.fetch("userId","").strip
    self.ProductId = params.fetch("productId","").strip
    self.Quantity = params.fetch("quantity","").strip
    self.OrderStatus = "null"
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
          if b_product.ProductId == product.ProductId 
            if names.empty?
              names << product.ProductName
            else
              names.each do |n|
                if n == product.ProductName
                  break
                else
                  names << product.ProductName
                end
              end
            end
          end
        end
      end
    end

    return names
  end


  
end