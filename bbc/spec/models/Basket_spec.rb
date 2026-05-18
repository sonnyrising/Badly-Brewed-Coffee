# frozen_string_literal: true

require_relative '../spec_helper'

#========== Basket Model Tests ==========#
RSpec.describe 'Bakset Management,' do

  context "add_bean_to_basket(params)" do
    let(:basket_instance) { Basket.new }
    it "correctly assigns fields, strips whitespace, updates the basket" do
      params = {
        'userId'      =>  ' 1 ',
        'productId'   =>  '   10  ',
        'quantity'    =>  ' 8   '
      }

      basket_instance.add_bean_to_basket(params)
      expect(basket_instance.UserId).to eq(1)
      expect(basket_instance.ProductId).to eq(10)
      expect(basket_instance.Quantity).to eq(8)
    end

    it "it ensures it generates a unique item ID" do
      Basket.dataset.delete
      Basket.insert(BasketId: 20, ItemId: 20)
      params = {
        'userId'      =>  ' 1 ',
        'productId'   =>  '   10  ',
        'quantity'    =>  ' 8   '
      }

      allow(basket_instance).to receive(:rand).and_return(20, 50)
      basket_instance.add_bean_to_basket(params)
          
      expect(basket_instance.ItemId).to eq(50)
    end
  end

  context "add_coffee_to_basket(params)" do
    let(:new_basket) { Basket.new }
    it "correctly assigns fields, strips whitespace, updates the basket" do
      params = {
        'userId'      =>  ' 2 ',
        'productId'   =>  '   12  ',
        'quantity'    =>  ' 10   ',
        'milk'        =>  ' condensed ',
        'size'        =>  ' Large '
      }

      new_basket.add_coffee_to_basket(params)
      expect(new_basket.UserId).to eq(2)
      expect(new_basket.ProductId).to eq(12)
      expect(new_basket.Quantity).to eq(10)
      expect(new_basket.Milk).to eq('condensed')
      expect(new_basket.Size).to eq('Large')
    end

    it "it ensures it generates a unique item ID" do
      Basket.dataset.delete
      Basket.insert(BasketId: 20, ItemId: 5)
      params = {
        'userId'      =>  ' 2 ',
        'productId'   =>  '   12  ',
        'quantity'    =>  ' 10   ',
        'milk'        =>  ' low fat   ',
        'size'        =>  ' Small '
      }

      allow(new_basket).to receive(:rand).and_return(5, 10)
      new_basket.add_coffee_to_basket(params)
          
      expect(new_basket.ItemId).to eq(10)
    end
  end

  
  describe ".getItemId(params)" do
    it "retrieves correct item ID" do
      Products.dataset.delete
      Basket.dataset.delete
      Products.insert(ProductId: 1)
      Basket.insert(ProductId: 1, ItemId: 10, BasketId: 1)

      params = {  'productId' => 1 }
      content = Basket.getItemId(params)

      expect(content).to eq(10)
    end
  end

  context "product_exists(params)" do
    let(:new_basket) { Basket.new }
    it "returns basket record if product entry exists" do
      Basket.dataset.delete
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1)
      params = {  'userId'  =>  1, 'productId'  => 1  }

      result = new_basket.product_exists(params)
      expect(result).not_to be_nil
      expect(result[:ProductId]).to eq(1)
    end
  end

  context "clear_guest_basket" do
    it "removes items belonging to guests" do
      Basket.dataset.delete
      Users.dataset.delete
      Products.dataset.delete
      Users.insert(UserId: 1)
      Users.insert(UserId: 99)
      Basket.insert(BasketId: 1, UserId: 1, ItemId: 10, Quantity: 10)
      Basket.insert(BasketId: 4, UserId: 1, ItemId: 20, Quantity: 10)
      Basket.insert(BasketId: 2, UserId: 99, ItemId: 40, Quantity: 20)

      Basket.clear_guest_basket
      guest_acc = Basket.where(UserId: 1).count
      non_guest = Basket.where(UserId: 99).count

      expect(guest_acc).to eq(0)
      expect(non_guest).to eq(1)
    end
  end

  context "user_check(params)" do
    let(:new_basket) { Basket.new }
    it "returns last basket record if user entry exists" do
      Basket.dataset.delete
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1)
      params = {  'userId'  =>  1 }

      result = new_basket.user_check(params)
      expect(result).not_to be_nil
      expect(result[:UserId]).to eq(1)
    end
  end

  context "product_check(params)" do
    let(:new_basket) { Basket.new }
    it "returns last basket record if product entry exists" do
      Basket.dataset.delete
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1)
      params = {  'productId'  => 1  }

      result = new_basket.product_check(params)
      expect(result).not_to be_nil
      expect(result[:ProductId]).to eq(1)
    end
  end
end