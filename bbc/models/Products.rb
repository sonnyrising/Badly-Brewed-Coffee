class Products < Sequel::Model

    def GetProductName(productId)
        return Products.where(ProductId: productId).get(:ProductName)
    end

    def GetProductPrice(productId)
        return Products.where(ProductId: productId).get(:Price)
    end

end