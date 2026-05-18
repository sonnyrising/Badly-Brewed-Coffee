# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe 'Generate Postage Label' do

  let!(:user) do
    Users.insert(
      UserID: 100,
      Username: 'postagetest',
      Email: 'test@gmail.com'
    )
  end

  describe 'outputs data onto label' do
    it 'creates the postage label page with the respective account details' do
      post '/staff/generatelabel', {
        'account-data' => user.id
      }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('postagetest')
      expect(last_response.body).to include('test@gmail.com')

      expect(last_response.body).to include('/imgs/PostageLabelTemplate.jpeg')
    end
  end
end