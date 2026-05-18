# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe 'Manager/Staff Shared Route Authentication Tests' do
  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'Manager123!' } } }
  let(:staff_session)   { { 'rack.session' => { user_id: 2, uname: 'Staff123!'   } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil     } } }

  manager_staff_shared_routes = [
    '/managestock',
    '/addproduct',
    '/orders',
    '/refunds',
    '/refunddetails'
  ]

  manager_staff_shared_routes.each do |route|
    describe "GET #{route}" do
      context 'when logged in as a manager' do
        it 'has a status code of 200 (OK)' do
          get route, {}, manager_session
          expect(last_response.status).to eq(200)
        end
      end

      context 'when logged in as staff' do
        it 'has a status code of 200 (OK)' do
          get route, {}, staff_session
          expect(last_response.status).to eq(200)
        end
      end

      context 'when not logged in' do
        it 'denies access and redirects (302)' do
          get route, {}, guest_session
          expect(last_response.status).to eq(302)
        end
      end
    end
  end
end
