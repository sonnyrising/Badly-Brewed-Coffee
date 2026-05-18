require_relative '../../spec_helper'

RSpec.describe 'Coffee and Bean Shop Logic' do
  let(:user_session) { { 'rack.session' => { userId: 1, uname: 'testuser' } } }

  before(:each) do
    spec_before
  end

  context 'bean shop page' do
    it 'loads bean shop page and displays products' do
      Products.insert(ProductId: 10, ProductName: 'Ethiopian Yirgacheffe', StockQuantity: 10, Price: 10, Roast: 'Medium', Bean: true)
      Products.insert(ProductId: 11, ProductName: 'Colombian Supremo', StockQuantity: 10, Price: 10, Roast: 'Medium', Bean: true)

      get '/user/shop', {}, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Ethiopian Yirgacheffe')
      expect(last_response.body).to include('Colombian Supremo')
    end

    it 'shows basket count on bean shop page' do
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1, Quantity: 2)

      get '/user/shop', {}, user_session

      expect(last_response.body).to include('2')
    end
  end

  context 'basket quantity management' do
    it 'adds item to basket and increases quantity' do
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1, Quantity: 1)

      post '/user/shop/add', { 'userId' => 1, 'productId' => 1 }, user_session

      basket_item = Basket.where(UserId: 1, ProductId: 1).first
      expect(basket_item.Quantity).to eq(2)
    end

    it 'subtracts item from basket or removes it' do
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1, Quantity: 1)

      post '/user/shop/subtract', { 'userId' => 1, 'productId' => 1 }, user_session

      expect(Basket.where(UserId: 1, ProductId: 1).first).to be_nil
    end

    it 'removes item from basket using delete action' do
      Basket.insert(BasketId: 1, UserId: 1, ProductId: 1, Quantity: 1)

      post '/user/shop/delete', { 'userId' => 1, 'productId' => 1 }, user_session

      expect(Basket.where(UserId: 1, ProductId: 1).first).to be_nil
    end
  end

  context 'bean filtering' do
    it 'filters beans by roast correctly' do
      Products.insert(
      ProductId: 10,
      ProductName: 'Ethiopian Yirgacheffe',
      Roast: 'Medium',
      Bean: true
    )

    Products.insert(
      ProductId: 11,
      ProductName: 'JorgeBean',
      Roast: 'Light',
      Bean: true
      )

      post '/user/filterbeans', { roast: 'Medium', search: '' }, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Ethiopian Yirgacheffe')
      expect(last_response.body).not_to include('JorgeBean')
    end

    it 'filters beans by search term' do
      Products.insert(ProductId: 20, ProductName: 'Colombian Supremo', Roast: 'Medium', Bean: true)
      Products.insert(ProductId: 21, ProductName: 'Random Coffee', Roast: 'Light', Bean: true)

      post '/user/filterbeans', { roast: '', search: 'Colombian' }, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('Colombian Supremo')
      expect(last_response.body).not_to include('JorgeBean')
    end

    it 'redirects when no bean filters are provided' do
      post '/user/filterbeans', { roast: '', search: '' }, user_session

      expect(last_response.status).to eq(302)
    end
  end

  context 'coffee filtering' do
    it 'filters coffees by roast' do
      post '/user/filtercoffees', { roast: 'Light', search: '' }, user_session
      expect(last_response.status).to eq(200)
    end

    it 'filters coffees by search term' do
      post '/user/filtercoffees', { roast: '', search: 'Ronicino' }, user_session
      expect(last_response.status).to eq(200)
    end

    it 'redirects when no coffee filters are provided' do
      post '/user/filtercoffees', { roast: '', search: '' }, user_session
      expect(last_response.status).to eq(302)
    end
  end
end