# frozen_string_literal: true

require 'capybara/rspec'
require 'rack/test'

require_relative '../spec_helper'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_manager
  visit '/login'
  fill_in 'username', with: 'Manager123!'
  fill_in 'password', with: 'Manager123!'
  click_button 'Log in'
end

RSpec.describe 'Refund Details Page', type: :feature do
  before(:each) do
    login_as_manager
    # Transaction 2 is seeded with RefundRequested: true
    visit '/refunddetails?transaction_id=2'
  end

  # -------------------------------------------------------------------------
  # Page load
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'displays the Refund Information heading' do
      expect(page).to have_content('Refund Information')
    end
  end

  # -------------------------------------------------------------------------
  # Refund information displayed
  # -------------------------------------------------------------------------

  describe 'Refund information' do
    it 'displays the correct transaction ID' do
      expect(page).to have_content('Transaction ID: 2')
    end

    it 'displays the cost with a £ symbol' do
      expect(page).to have_content('£')
      expect(page).to have_content('15')
    end

    it 'displays the refund reason' do
      expect(page).to have_content('Reason:')
      expect(page).to have_content('Cold coffee')
    end

    it 'displays the formatted order date' do
      expect(page).to have_content('Date Ordered:')
    end

    it 'displays the transaction status' do
      expect(page).to have_content('Status:')
      expect(page).to have_content('Pending')
    end
  end

  # -------------------------------------------------------------------------
  # Navigation
  # -------------------------------------------------------------------------

  describe 'Navigation' do
    it 'renders a Back button linking to the refunds page' do
      expect(page).to have_link('Back', href: '/refunds')
    end

    it 'navigates back to the refunds page when Back is clicked' do
      click_link 'Back'
      expect(page).to have_current_path('/refunds')
    end
  end

  # -------------------------------------------------------------------------
  # Accept and Decline buttons
  # -------------------------------------------------------------------------

  describe 'Accept and Decline buttons' do
    it 'renders an Accept button' do
      expect(page).to have_button('Accept')
    end

    it 'renders a Decline button' do
      expect(page).to have_button('Decline')
    end

    it 'the Accept button links to the correct accept URL' do
      accept_btn = page.find('button.btn-green')
      expect(accept_btn['onclick']).to include('/refunds?message=accept&refund_id=2')
    end

    it 'the Decline button links to the correct decline URL' do
      decline_btn = page.find('button.btn-red')
      expect(decline_btn['onclick']).to include('/refunds?message=decline&refund_id=2')
    end
  end

  # -------------------------------------------------------------------------
  # Accepting a refund
  # -------------------------------------------------------------------------

  describe 'Accepting a refund' do
    before do
      # Bypass the JS confirm dialogue by visiting the accept URL directly
      visit '/refunds?message=accept&refund_id=2'
    end

    it 'marks the transaction as Refunded in the database' do
      expect(Transactions.where(TransactionId: 2).get(:Refunded)).to be_truthy
    end

    it 'clears the RefundRequested flag' do
      expect(Transactions.where(TransactionId: 2).get(:RefundRequested)).to be_falsy
    end

    it 'updates the transaction status to Refunded' do
      expect(Transactions.where(TransactionId: 2).get(:Status)).to eq('Refunded')
    end

    it 'redirects to the refunds page with a success banner' do
      expect(page).to have_current_path('/refunds', ignore_query: true)
      expect(page).to have_content('Refund has been accepted.')
    end
  end

  # -------------------------------------------------------------------------
  # Declining a refund
  # -------------------------------------------------------------------------

  describe 'Declining a refund' do
    before do
      visit '/refunds?message=decline&refund_id=2'
    end

    it 'clears the RefundRequested flag' do
      expect(Transactions.where(TransactionId: 2).get(:RefundRequested)).to be_falsy
    end

    it 'does not mark the transaction as Refunded' do
      expect(Transactions.where(TransactionId: 2).get(:Refunded)).to be_falsy
    end

    it 'does not update the status to Refunded' do
      expect(Transactions.where(TransactionId: 2).get(:Status)).not_to eq('Refunded')
    end

    it 'redirects to the refunds page with a decline banner' do
      expect(page).to have_current_path('/refunds', ignore_query: true)
      expect(page).to have_content('Refund has been declined.')
    end
  end

  # -------------------------------------------------------------------------
  # Access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/refunddetails?transaction_id=2'
      end

      it 'redirects away from the refund details page' do
        expect(page.current_path).not_to eq('/refunddetails')
      end
    end
  end
end
