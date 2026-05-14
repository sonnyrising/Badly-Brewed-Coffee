# frozen_string_literal: true

require_relative '../../spec_helper'

def admin_dummy
  Users.insert(UserId: 1, Username: 'admin', AccountType: 'admin')
end

# =============================================================================
# Viewing Feedback Tests
# =============================================================================
RSpec.describe 'For feedback listing,' do
  let(:admin_session) { { 'rack.session' => { userId: 1, uname: 'admin' } } }

  context 'when no filter is applied' do
    it 'it returns 200 and displays all feedback entries' do
      Users.dataset.delete
      admin_dummy
      get '/admin/feedback', {}, admin_session
      expect(last_response.status).to eq(200)
    end
  end

  context 'when a filter is applied' do
    it 'it returns 302 and displays all refund feedback entries' do
      Feedbacks.dataset.delete
      Users.dataset.delete
      admin_dummy
      Feedbacks.insert(RefundRequest: 'Yes', TicketNumber: 1001, RefundReason: 'test reason')

      post '/admin/feedback/filter', { 'filter' => 'refund_issue' }, admin_session
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('admin/feedback')
    end
  end

  context 'when deleting a feedback entry' do
    it 'it successfully deletes a feedback entry and redirects' do
      Users.dataset.delete
      admin_dummy
      Feedbacks.dataset.delete
      Feedbacks.insert(FeedbackId: 1)
      expect(Feedbacks.where(FeedbackId: 1).count).to eq(1)
      post '/admin/feedback/delete', { feedbackId: 1 }, admin_session
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq('http://example.org/admin/feedback')
      expect(Feedbacks.where(FeedbackId: 1).count).to eq(0)
    end
  end
end
