# frozen_string_literal: true

require_relative '../spec_helper'

#========== Customisations Model Tests ==========#
RSpec.describe 'Customisations Management,' do

  let(:customisation) { Customisations.new }
  context "addToCustomisations(params)" do
    it "correctly assigns fields, strips whitespace, updates the basket" do
      params = {
        'productId'   =>  '   10  ',
        'MilkType'    =>  ' Test Coffee   ',
        'CoffeeSize'  =>  '   Small     '
      }

      customisation.addToCustomisations(params)
      expect(customisation.ProductId).to eq(10)
      expect(customisation.MilkType).to eq('Test Coffee')
      expect(customisation.CoffeeSize).to eq('Small')
    end
  end

  context "Item ID" do
    it ".getItemID(user, product)" do
      Users.dataset.delete
      Products.dataset.delete
      Basket.dataset.delete
      Customisations.dataset.delete

      Users.insert(UserId: 10)
      Products.insert(ProductId: 1)
      Basket.insert(UserId: 10, ProductId: 1, BasketId: 1, ItemId: 100)
      Customisations.insert(ItemId: 100, ProductId: 1)

      result = Customisations.getItemID(10, 1)
      expect(result).to eq(100)
    end

    it ".setItemId(product)" do
      Products.dataset.delete
      Basket.dataset.delete
      Customisations.dataset.delete
      Products.insert(ProductId: 10)
      Basket.insert(BasketId: 1, ProductId: 10, ItemId: 67)
      Customisations.insert(ItemId: 67, ProductId: 10)

      custom = Customisations.new
      custom.setItemId(10)

      custom = Customisations.first(ItemId: 67)
      expect(custom).not_to be_nil
      expect(custom[:ItemId]).to eq(67)
    end
  end

  context "Milk Type" do
    it ".getMilkType(item)" do
      Customisations.dataset.delete
      custom = Customisations.insert(ProductId: 1, ItemId: 1, MilkType: 'Test')

      result = Customisations.getMilkType(1)
      expect(result).to eq('Test')
    end
  end

  context "Coffee Size" do
    it ".getCoffeeSize(item)" do
      Customisations.dataset.delete
      custom = Customisations.insert(ProductId: 1, ItemId: 1, CoffeeSize: 'Large')

      result = Customisations.getCoffeeSize(1)
      expect(result).to eq('Large')
    end
  end
end



