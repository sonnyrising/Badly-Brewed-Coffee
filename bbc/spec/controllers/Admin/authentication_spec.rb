# frozen_string_literal: true

require_relative '../../spec_helper'

# =============================================================================
# Authentication Tests
# =============================================================================
RSpec.describe 'Authentication Tests' do
  let(:admin_session)   { { 'rack.session' => { user_id: 1, uname: 'admin' } } }
  let(:manager_session) { { 'rack.session' => { user_id: 2, uname: 'manager' } } }
  let(:guest_session)   { { 'rack.session' => { user_id: nil, uname: nil } } }

  admin_get_routes = [
    '/admin/homepage',
    '/admin/accounts',
    '/admin/views',
    '/admin/feedback',
    '/admin/accounts/create'
  ]

  admin_post_routes = [
    '/admin/views/manager',           '/admin/views/barista',
    '/admin/views/user',              '/admin/feedback/filter',
    '/admin/feedback/delete',         '/admin/accounts/create',
    '/admin/accounts/create/submit',  '/admin/accounts/filter',
    '/admin/accounts/view',           '/admin/accounts/edit',
    '/admin/accounts/edit/update',    '/admin/run-inactivity-check'
  ]

  test_params = { Username: 'test', userId: 1, feedbackId: 1,
                  'id-data': 1, 'search-filter': 'test',
                  'account-data': 1, 'username-data': 'Alice',
                  'email-data': 'Alice@gmail.com', 'loyaltypoint-data': 10,
                  'inactivity-data': 7 }

  admin_get_routes.each do |route|
    describe "GET #{route}" do
      context 'when logged in as an admin' do
        it 'has a status code of 200 (OK)' do
          get route, test_params, admin_session
          expect(last_response.status).to eq(200)
        end
      end

      context 'when logged in as manager' do
        it 'denies access and redirects (302)' do
          get route, {}, manager_session
          expect(last_response.status).to eq(302)
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

  admin_post_routes.each do |route|
    describe "POST #{route}" do
      context 'logged in as an admin' do
        it 'allows the admin to perform the operations' do
          post route, test_params, admin_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).not_to eq('http://example.org/')
        end
      end

      context 'not logged in as an admin' do
        it 'denies access and redirects' do
          post route, test_params, guest_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).to eq('http://example.org/')
        end
      end
    end
  end
end
