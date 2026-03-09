class Products < Sequel::Model

    def self.GetProductName(productId)
        return Products.where(ProductId: productId).get(:ProductName)
    end

    def self.GetProductPrice(productId)
        return Products.where(ProductId: productId).get(:Price)
    end

end