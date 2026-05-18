require_relative '../../spec_helper'

RSpec.describe 'Feedback and Contact Us Logic' do
  let(:user_session) { { 'rack.session' => { userId: 1, uname: 'testuser' } } }

  before(:each) do
    spec_before
  end

  context 'contact us pages' do
    it 'loads the contact us page successfully' do
      get '/user/contact_us_page', {}, user_session

      expect(last_response.status).to eq(200)
    end

    it 'loads the feedback submission page successfully' do
      get '/user/feedback_page_submission', {}, user_session

      expect(last_response.status).to eq(200)
    end
  end

  context 'feedback submission' do
    it 'submits feedback successfully without refund request' do
      expect(Feedbacks.count).to eq(1)

      post '/user/feedback-page-submit', {
        issue: 'Bean bag was slightly ripped',
        request: 'No',
        reason: 'no',
        transaction_id: '1'
      }, user_session

      expect(last_response.status).to eq(302)
    end

    it 'submits feedback successfully with refund request' do
      post '/user/feedback-page-submit', {
        issue: 'Order damaged',
        request: 'Yes',
        reason: 'Damaged cup',
        transaction_id: '1'
      }, user_session

      expect(last_response.status).to eq(302)

      transaction = Transactions[1]

      expect(transaction.RefundRequested).to eq(true)
    end

    it 'fails when refund has already been requested' do
      post '/user/feedback-page-submit', {
        issue: "Beans didn't arrive",
        request: 'Yes',
        reason: 'Poor service',
        transaction_id: '2'
      }, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('already been requested for a refund')
    end

    it 'fails when transaction has already been refunded' do
      Transactions.where(TransactionId: 1).update(Refunded: true)

      post '/user/feedback-page-submit', {
        issue: 'Refund issued',
        request: 'Yes',
        reason: 'Milk type was wrong',
        transaction_id: '1'
      }, user_session

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('already been refunded')
    end
  end
end