# frozen_string_literal: true

class Customisations < Sequel::Model(:Customisations)
  def addToCustomisations(params)
    self.ItemId = nil
    self.ProductId = params.fetch('productId', '').strip
    self.MilkType = params.fetch('MilkType', '').strip
    self.CoffeeSize = params.fetch('CoffeeSize', '').strip

  end
  
  def self.getItemID(user, product)
    Basket.where(UserId: user, ProductId: product).map(:ItemId)
  end 

  def setItemId(product)
    item = Basket.where(ProductId: product).get(:ItemId)
    Customisations.where(ItemId: item).update(ItemId: item)
  end

  def self.getItemId(product)
    Customisations.where(ProductId: product).get(:ItemId)
  end

  def self.getMilkType(item)
    Customisations.where(ItemId: item).get(:MilkType)
  end

  def self.getCoffeeSize(item)
    Customisations.where(ItemId: item).get(:CoffeeSize)
  end
end