require_relative '../../spec_helper'

RSpec.describe 'Coffee and Bean Shop Logic' do
  let(:staff_session) { { 'rack.session' => { userId: 100, uname: 'teststaff' } } }

  before(:each) do
    spec_before
  end

  context 'shop page' do
    it 'loads shop page and displays products' do
      Products.insert(ProductId: 10, ProductName: 'Ethiopian Yirgacheffe', StockQuantity: 10, Price: 10, Roast: 'Medium', Bean: true)
      Products.insert(ProductId: 11, ProductName: 'Steffspresso', StockQuantity: 10, Price: 10, Roast: 'Medium', Bean: false)

      post '/staff/selectproducts', {}, staff_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Ethiopian Yirgacheffe')
      expect(last_response.body).to include('Steffspresso')
    end

    it 'shows basket count on shop page' do
      Basket.insert(BasketId: 1, UserId: 100, ProductId: 1, Quantity: 2)

      get '/staff/selectproducts', {}, staff_session

      expect(last_response.body).to include('2')
    end
  end

  context 'basket quantity management' do
    it 'adds item to basket and increases quantity' do
      Basket.insert(BasketId: 1, UserId: 100, ProductId: 1, Quantity: 1)

      post '/staff/shop/add', { 'userId' => 100, 'productId' => 1 }, staff_session

      basket_item = Basket.where(UserId: 1, ProductId: 1).first
      expect(basket_item.Quantity).to eq(2)
    end

    it 'subtracts item from basket or removes it' do
      Basket.insert(BasketId: 1, UserId: 100, ProductId: 1, Quantity: 1)

      post '/staff/shop/subtract', { 'userId' => 100, 'productId' => 1 }, staff_session

      expect(Basket.where(UserId: 100, ProductId: 1).first).to be_nil
    end

    it 'removes item from basket using delete action' do
      Basket.insert(BasketId: 1, UserId: 100, ProductId: 1, Quantity: 1)

      post '/staff/shop/delete', { 'userId' => 100, 'productId' => 1 }, staff_session

      expect(Basket.where(UserId: 100, ProductId: 1).first).to be_nil
    end
  end
end