# frozen_string_literal: true

class Customisations < Sequel::Model(:Customisations)
  def addToCustomisations(params)
    self.ItemId = rand(1000000)
    self.ProductId = params.fetch('productId', '').strip
    self.MilkType = params.fetch('MilkType', '').strip
    self.CoffeeSize = params.fetch('CoffeeSize', '').strip

    Basket.setItemId(itemId: self.ItemId, productId: self.ProductId)
  end

  def self.getItemID(user, product)
    Customisations.where(UserId: user, ProductId: product).get(:ItemId)
  end 

  def getMilkType(item)
    Customisations.where(ItemId: item).get(:MilkType)
  end

  def getCoffeeSize(item)
    Customisations.where(ItemId: item).get(:CoffeeSize)
  end
end