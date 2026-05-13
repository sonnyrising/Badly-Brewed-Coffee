require 'capybara/rspec'
require 'rack/test'

require_relative '../spec_helper'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_manager
  visit '/login'
  fill_in 'uname', with: 'manager'
  fill_in 'pword', with: 'manager'
  click_button 'Log in'
end

RSpec.describe 'Refunds Page', type: :feature do

  before(:each) do
    login_as_manager
    visit '/refunds'
  end


  # -------------------------------------------------------------------------
  # Page load
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'displays the Pending Refunds heading' do
      expect(page).to have_content('Pending Refunds')
    end

    it 'displays the In-Store Refunds heading' do
      expect(page).to have_content('In-Store Refunds')
    end
  end

  # -------------------------------------------------------------------------
  # Sidebar navigation
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
    it 'shows the View Dashboard button for a manager' do
      expect(page).to have_link('View Dashboard')
    end

    it 'navigates to the manager dashboard when View Dashboard is clicked' do
      click_link 'View Dashboard'
      expect(page).to have_current_path('/manager/homepage')
    end

    it 'navigates to manage stock when Manage Stock is clicked' do
      click_link 'Manage Stock'
      expect(page).to have_current_path('/managestock')
    end

    it 'navigates to orders when View Orders is clicked' do
      click_link 'View Orders'
      expect(page).to have_current_path('/orders')
    end

    it 'stays on refunds when View Refunds is clicked' do
      click_link 'View Refunds'
      expect(page).to have_current_path('/refunds')
    end

    it 'logs out when Logout is clicked' do
      click_link 'Logout'
      expect(page.current_path).to eq('/login').or eq('/')
    end
  end

  # -------------------------------------------------------------------------
  # Pending refunds table
  # -------------------------------------------------------------------------

  describe 'Pending refunds table' do
    context 'when there are no pending refunds' do
      before do
        Transactions.dataset.update(RefundRequested: false)
        visit '/refunds'
      end

      it 'displays the no pending refunds message' do
        expect(page).to have_content('No pending refunds.')
      end
    end

    context 'when a pending refund exists' do
      before do
        Transactions.where(TransactionId: 2).update(RefundRequested: true)
        visit '/refunds'
      end

      it 'renders the correct column headers' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).to have_content('Order ID')
          expect(page).to have_content('Cost')
          expect(page).to have_content('Date Ordered')
          expect(page).to have_content('Status')
        end
      end

      it 'displays the transaction ID' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).to have_content('2')
        end
      end

      it 'displays the cost with a £ symbol' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).to have_content('£')
        end
      end

      it 'renders a View button linking to the refund details page' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).to have_link('View', href: '/refunddetails?transaction_id=2')
        end
      end

      it 'navigates to the refund details page when View is clicked' do
        within('.glass-card', text: 'Pending Refunds') do
          click_link 'View'
        end
        expect(page).to have_current_path('/refunddetails', ignore_query: true)
      end
    end
  end

  # -------------------------------------------------------------------------
  # Alert banner — accepting a refund
  # -------------------------------------------------------------------------

  describe 'Alert banner' do
    context 'when a refund is accepted' do
      before do
        visit '/refunds?message=accept&refund_id=2'
      end

      it 'shows the accepted alert banner' do
        expect(page).to have_css('.alert-banner')
        expect(page).to have_content('Refund has been accepted.')
      end

      it 'shows the payment provider notification message' do
        expect(page).to have_content('The Payment Provider has been notified of the refund.')
      end

      it 'shows the email receipt message' do
        expect(page).to have_content('The user has been emailed a receipt for the refund.')
      end

      it 'applies the green style to the banner' do
        expect(page).to have_css('.alert-banner.btn-green')
      end

      it 'marks the transaction as no longer requesting a refund' do
        expect(Transactions.where(TransactionId: 2).get(:RefundRequested)).to be_falsy
      end

      it 'updates the transaction status to Refunded' do
        expect(Transactions.where(TransactionId: 2).get(:Status)).to eq('Refunded')
      end

      it 'removes the refund from the pending refunds table' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).not_to have_link('View', href: '/refunddetails?transaction_id=2')
        end
      end
    end

    context 'when a refund is declined' do
      before do
        Transactions.where(TransactionId: 2).update(RefundRequested: true)
        visit '/refunds?message=decline&refund_id=2'
      end

      it 'shows the declined alert banner' do
        expect(page).to have_css('.alert-banner')
        expect(page).to have_content('Refund has been declined.')
      end

      it 'applies the red style to the banner' do
        expect(page).to have_css('.alert-banner.btn-red')
      end

      it 'does not show the payment provider message' do
        expect(page).not_to have_content('The Payment Provider has been notified of the refund.')
      end

      it 'marks the transaction as no longer requesting a refund' do
        expect(Transactions.where(TransactionId: 2).get(:RefundRequested)).to be_falsy
      end

      it 'does not mark the transaction as Refunded' do
        expect(Transactions.where(TransactionId: 2).get(:Status)).not_to eq('Refunded')
      end

      it 'removes the refund from the pending refunds table' do
        within('.glass-card', text: 'Pending Refunds') do
          expect(page).not_to have_link('View', href: '/refunddetails?transaction_id=2')
        end
      end
    end
  end

  # -------------------------------------------------------------------------
  # In-store refund form
  # -------------------------------------------------------------------------

  describe 'In-store refund form' do

    def submit_instore_refund(reason: 'Cold coffee', transaction_id: '1')
      within('.glass-card', text: 'In-Store Refunds') do
        fill_in 'reason',         with: reason
        fill_in 'transaction_id', with: transaction_id
        click_button 'Submit'
      end
    end

    context 'with a valid transaction ID and reason' do
      it 'creates a feedback record in the database' do
        count_before = Feedbacks.count
        submit_instore_refund
        expect(Feedbacks.count).to eq(count_before + 1)
      end

      it 'accepts a reason up to 250 characters' do
        count_before = Feedbacks.count
        submit_instore_refund(reason: 'A' * 250)
        expect(Feedbacks.count).to eq(count_before + 1)
      end
    end

    context 'with a non-existent transaction ID' do
      it 'does not create a feedback record' do
        count_before = Feedbacks.count
        submit_instore_refund(transaction_id: '99999')
        expect(Feedbacks.count).to eq(count_before)
      end

      it 'shows an error message' do
        submit_instore_refund(transaction_id: '99999')
        expect(page).to have_content('Transaction ID not found')
      end
    end

    context 'when the transaction has already been refunded' do
      before do
        Transactions.where(TransactionId: 1).update(Refunded: true)
      end

      it 'does not create a feedback record' do
        count_before = Feedbacks.count
        submit_instore_refund(transaction_id: '1')
        expect(Feedbacks.count).to eq(count_before)
      end

      it 'shows an error message' do
        submit_instore_refund(transaction_id: '1')
        expect(page).to have_content('already been refunded')
      end
    end

    context 'when a refund has already been requested for the transaction' do
      before do
        Transactions.where(TransactionId: 1).update(RefundRequested: true)
      end

      it 'does not create a duplicate feedback record' do
        count_before = Feedbacks.count
        submit_instore_refund(transaction_id: '1')
        expect(Feedbacks.count).to eq(count_before)
      end

      it 'shows an error message' do
        submit_instore_refund(transaction_id: '1')
        expect(page).to have_content('already been requested for a refund')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/refunds'
      end

      it 'redirects away from the refunds page' do
        expect(page.current_path).not_to eq('/refunds')
      end
    end
  end
end