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

      allow(customisation).to receive(:rand).and_return(12345)
      expect(Basket).to receive(:setItemId).with(itemId: 12345, productId: '10')

      customisation.addToCustomisations(params)
      expect(customisation.ItemId).to eq(12345)
      expect(customisation.ProductId).to eq('10')
      expect(customisation.MilkType).to eq('Test Coffee')
      expect(customisation.CoffeeSize).to eq('Small')
    end
  end

  context "Item ID" do
    it ".getItemID(user, product)" do
      Customisations.dataset.delete
      custom = Customisations.insert(ProductId: 1, ItemId: 1, UserId: 99)

      result = Customisations.getItemID(99, 1)
      expect(result).to eq(1)
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



