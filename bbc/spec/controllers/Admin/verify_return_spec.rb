# frozen_string_literal: true

RSpec.describe 'When visiting GET' do
  let(:admin_session) { { 'rack.session' => { userId: 1, uname: 'admin' } } }

  context '/admin/views/manager' do
    it 'verifies the return page' do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'admin', AccountType: 'admin')
      post '/admin/views/manager', {}, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq('http://example.org/manager/homepage')
    end
  end
end
