require 'capybara/rspec'
require 'rack/test'

require_relative '../../../app'

Capybara.app = Sinatra::Application
Capybara.default_driver = :rack_test

def login_as_manager
  visit '/login'
  fill_in 'uname', with: 'manager'
  fill_in 'pword', with: 'manager'
  click_button 'Log in'
end

def submit_invalid_discount(value)
  first_row = page.first('tbody tr')
  first_row.find('input[type="number"]').set(value)
  first_row.click_button('Update Loyalty Discount')
end

RSpec.describe 'Adjust Loyalty Page', type: :feature do

  before(:each) do
    login_as_manager
    visit '/manager/adjustloyalty'
  end

  # -------------------------------------------------------------------------
  # Test the page loads
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'displays the correct page heading' do
      expect(page).to have_content('Adjust Loyalty Discount for Customers')
    end

    it 'displays the subheading explaining what the discount does' do
      expect(page).to have_content('Customers will have this discount applied to all orders')
    end

    it 'renders the navigation bar with all links' do
      within('nav') do
        expect(page).to have_link('Dashboard',      href: '/manager/homepage')
        expect(page).to have_link('Adjust Loyalty', href: '/manager/adjustloyalty')
        expect(page).to have_link('View Feedback',  href: '/manager/viewfeedback')
      end
    end

    it 'renders all sidebar navigation buttons' do
      expect(page).to have_link('View Dashboard')
      expect(page).to have_link('Step in as Barista')
      expect(page).to have_link('Manage Stock')
      expect(page).to have_link('View Orders')
      expect(page).to have_link('View Refunds')
    end

    it 'renders a logout link' do
      expect(page).to have_link('Logout', href: '/logout')
    end

    it 'greets the manager by name' do
      expect(page).to have_content('Welcome Back Kenny!')
    end
  end

  # -------------------------------------------------------------------------
  # Test the user table renders properly
  # -------------------------------------------------------------------------

  describe 'User table' do
    it 'renders all required column headers' do
      within('table thead') do
        ['User ID', 'Username', 'Coffees Ordered',
         'Loyalty Points', 'Loyalty Discount', 'Action'].each do |heading|
          expect(page).to have_content(heading)
        end
      end
    end

    context 'when there are no active (non-suspended) users' do
      before do
        allow(Users).to receive(:where).with(Suspended: 0).and_return([])
        visit '/manager/adjustloyalty'
      end

      it 'displays the empty-state message' do
        expect(page).to have_content('No Users.')
      end

      it 'renders no discount input fields' do
        expect(page).not_to have_css('tbody input[type="number"]')
      end
    end

    context 'when active users exist' do
      it 'renders at least one user row' do
        expect(page.all('tbody tr').length).to be >= 1
      end

      it 'shows a numeric discount input in every user row' do
        page.all('tbody tr').each do |row|
          expect(row).to have_css('input[type="number"]')
        end
      end

      it 'shows an "Update Loyalty Discount" button in every user row' do
        page.all('tbody tr').each do |row|
          expect(row).to have_button('Update Loyalty Discount')
        end
      end

      it 'pre-populates the discount field with the current discount value' do
        input = page.first('tbody tr').find('input[type="number"]')
        # LoyaltyDiscount is stored as a float in the DB (e.g. "0.0", "10.0"),
        # so we match an integer optionally followed by .0
        expect(input.value).to match(/\A\d+(\.\d+)?\z/)
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test the update form
  # -------------------------------------------------------------------------

  describe 'Discount update forms' do
    it 'each form targets POST /manager/updatediscount' do
      page.all('form.update-discount').each do |form|
        expect(form['action']).to eq('/manager/updatediscount')
        expect(form['method'].downcase).to eq('post')
      end
    end

    it 'each form carries a hidden numeric user_id field' do
      page.all('form.update-discount').each do |form|
        hidden = form.find('input[type="hidden"][name="user_id"]', visible: false)
        expect(hidden.value).to match(/\A\d+\z/)
      end
    end

    it 'each discount input is named "discount"' do
      page.all('input[type="number"]').each do |input|
        expect(input['name']).to eq('discount')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test valid discounts
  # -------------------------------------------------------------------------

  describe 'POST /manager/updatediscount — valid input' do
    let(:first_row)      { page.first('tbody tr') }
    let(:discount_input) { first_row.find('input[type="number"]') }

    it 'accepts a boundary value of 0 and redirects back to the page' do
      discount_input.set('0')
      first_row.click_button('Update Loyalty Discount')
      expect(page).to have_current_path('/manager/adjustloyalty')
    end

    it 'accepts a mid-range value of 50 and redirects back to the page' do
      discount_input.set('50')
      first_row.click_button('Update Loyalty Discount')
      expect(page).to have_current_path('/manager/adjustloyalty')
    end

    it 'accepts the boundary value of 100 and redirects back to the page' do
      discount_input.set('100')
      first_row.click_button('Update Loyalty Discount')
      expect(page).to have_current_path('/manager/adjustloyalty')
    end

    it 'persists the updated discount value in the rendered table' do
      discount_input.set('42')
      first_row.click_button('Update Loyalty Discount')
      # DB stores as float so the rendered value may be "42.0" — compare as integer
      rendered = page.first('tbody tr').find('input[type="number"]').value.to_i
      expect(rendered).to eq(42)
    end

    it 'does not show an error alert on success' do
      discount_input.set('10')
      first_row.click_button('Update Loyalty Discount')
      expect(page).not_to have_css('.alert-banner')
    end
  end

  # -------------------------------------------------------------------------
  # Test Invalid discounts
  # -------------------------------------------------------------------------

  describe 'POST /manager/updatediscount — invalid input' do
    shared_examples 'shows an error alert' do
      it 'renders the adjust loyalty page content' do
        expect(page).to have_content('Adjust Loyalty Discount for Customers')
      end

      it 'displays the validation error message' do
        expect(page).to have_css('.alert-banner')
        expect(page).to have_content('Please enter a valid discount percentage (0-100).')
      end

      it 'still renders the user table' do
        expect(page).to have_css('table tbody tr')
      end
    end

    context 'when the discount field is blank' do
      before { submit_invalid_discount('') }
      include_examples 'shows an error alert'
    end

    context 'when the discount is 101 (above maximum)' do
      before { submit_invalid_discount('101') }
      include_examples 'shows an error alert'
    end

    context 'when the discount contains letters' do
      before { submit_invalid_discount('abc') }
      include_examples 'shows an error alert'
    end

    context 'when the discount is negative' do
      before { submit_invalid_discount('-5') }
      include_examples 'shows an error alert'
    end

    context 'when the discount is a decimal number' do
      before { submit_invalid_discount('25.5') }
      include_examples 'shows an error alert'
    end
  end

  # -------------------------------------------------------------------------
  # Test the alert banner
  # -------------------------------------------------------------------------

  describe 'Alert banner' do
    before { submit_invalid_discount('101') }

    it 'renders the alert banner after an invalid submission' do
      expect(page).to have_css('.alert-banner')
    end

    it 'renders a close button inside the alert banner' do
      expect(page).to have_css('.alert-banner .alert-close-btn')
    end

    it 'displays the correct error text in the banner' do
      within('.alert-banner') do
        expect(page).to have_content('Please enter a valid discount percentage (0-100).')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/manager/adjustloyalty'
      end

      it 'redirects to the login page' do
        expect(page.current_path).to eq('/login')
      end

      it 'does not render the loyalty table' do
        expect(page).not_to have_css('table')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test sidebar navigation
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
    it 'navigates to the manager dashboard' do
      click_link 'View Dashboard'
      expect(page).to have_current_path('/manager/homepage')
    end

    it 'navigates to manage stock' do
      click_link 'Manage Stock'
      expect(page).to have_current_path('/managestock')
    end

    it 'navigates to orders' do
      click_link 'View Orders'
      expect(page).to have_current_path('/orders')
    end

    it 'navigates to refunds' do
      click_link 'View Refunds'
      expect(page).to have_current_path('/refunds')
    end
  end

  # -------------------------------------------------------------------------
  # Test the top navigation bar
  # -------------------------------------------------------------------------

  describe 'Top navigation bar' do
    it 'navigates to View Feedback' do
      within('nav') { click_link 'View Feedback' }
      expect(page).to have_current_path('/manager/viewfeedback')
    end

    it 'navigates to Dashboard' do
      within('nav') { click_link 'Dashboard' }
      expect(page).to have_current_path('/manager/homepage')
    end

    it 'navigates to Adjust Loyalty' do
      within('nav') { click_link 'Adjust Loyalty' }
      expect(page).to have_current_path('/manager/adjustloyalty')
    end
  end
end