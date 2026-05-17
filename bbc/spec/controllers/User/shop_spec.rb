require_relative '../../spec_helper'

RSpec.describe 'Coffee and Bean Shop Logic' do
  let(:user_session) { { 'rack.session' => { userId: 1, uname: 'testuser' } } }

  before(:each) do
    spec_before
  end

  context 'shop pages' do
    it 'loads the bean shop page successfully' do
      get '/user/shop', {}, user_session

      expect(last_response.status).to eq(200)
    end

    it 'loads the coffee shop page successfully' do
      get '/user/coffeeshop', {}, user_session

      expect(last_response.status).to eq(200)
    end
  end

  context 'adding products to basket' do
    it 'adds a bean product to basket successfully' do
      Products.insert(
        ProductId: 10,
        ProductName: 'Jorge bean',
        StockQuantity: 15,
        Price: 12.50,
        ProductImage: 'jorgeBean.jpg',
        ProductDescription: 'Mexican beans',
        Origin: 'Brazil',
        Roast: 'Dark',
        Bean: true
      )

      expect(Basket.count).to eq(0)

      post '/user/shop', {
        ProductId: 10,
        Quantity: 1,
        UserId: 1
      }, user_session

      expect(last_response.status).to eq(200)
      expect(Basket.count).to eq(1)
    end

    it 'adds a coffee product to basket successfully' do
      Products.insert(
        ProductId: 11,
        ProductName: 'Colombian supremo',
        StockQuantity: 20,
        Price: 4.50,
        ProductImage: 'Colombian_supremo.jpg',
        ProductDescription: 'Colombian drink',
        Origin: 'Colombia',
        Roast: 'Medium',
        Bean: false
      )

      expect(Basket.count).to eq(0)

      post '/user/shop', {
        ProductId: 11,
        Quantity: 1,
        UserId: 1
      }, user_session

      expect(last_response.status).to eq(200)
      expect(Basket.count).to eq(1)
    end
  end

  context 'basket quantity management' do
    it 'increases item quantity in basket' do
      Basket.insert(
        BasketId: 1,
        UserId: 1,
        ProductId: 1,
        Quantity: 1
      )

      post '/user/shop/add', {
        'userId' => 1,
        'productId' => 1
      }, user_session

      expect(last_response.status).to eq(200)

      basket_item = Basket.where(UserId: 1, ProductId: 1).first
      expect(basket_item.Quantity).to eq(2)
    end

    it 'decreases item quantity in basket' do
      Basket.insert(
        BasketId: 1,
        UserId: 1,
        ProductId: 1,
        Quantity: 2
      )

      post '/user/shop/subtract', {
        'userId' => 1,
        'productId' => 1
      }, user_session

      expect(last_response.status).to eq(200)

      basket_item = Basket.where(UserId: 1, ProductId: 1).first
      expect(basket_item.Quantity).to eq(1)
    end

    it 'removes item from basket' do
      Basket.insert(
        BasketId: 1,
        UserId: 1,
        ProductId: 1,
        Quantity: 1
      )

      expect(Basket.count).to eq(1)

      post '/user/shop/delete', {
        ProductId: 1,
        UserId: 1
      }, user_session

      expect(last_response.status).to eq(200)
    end
  end

  context 'bean filtering' do
    it 'filters beans by roast' do
      post '/user/filterbeans', {
        roast: 'Medium',
        search: ''
      }, user_session

      expect(last_response.status).to eq(200)
    end

    it 'filters beans by search term' do
      post '/user/filterbeans', {
        roast: '',
        search: 'Colombian'
      }, user_session

      expect(last_response.status).to eq(200)
    end

    it 'redirects when no bean filters are provided' do
      post '/user/filterbeans', {
        roast: '',
        search: ''
      }, user_session

      expect(last_response.status).to eq(302)
    end
  end

  context 'coffee filtering' do
    it 'filters coffees by roast' do
      post '/user/filtercoffees', {
        roast: 'Light',
        search: ''
      }, user_session

      expect(last_response.status).to eq(200)
    end

    it 'filters coffees by search term' do
      post '/user/filtercoffees', {
        roast: '',
        search: 'Ronicino'
      }, user_session

      expect(last_response.status).to eq(200)
    end

    it 'redirects when no coffee filters are provided' do
      post '/user/filtercoffees', {
        roast: '',
        search: ''
      }, user_session

      expect(last_response.status).to eq(302)
    end
  end
end