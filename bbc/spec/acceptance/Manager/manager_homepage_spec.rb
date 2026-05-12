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

RSpec.describe 'Manager Homepage', type: :feature do

  before(:each) do
    login_as_manager
    visit '/manager/homepage'
  end

  # -------------------------------------------------------------------------
  # Test the page loads
  # -------------------------------------------------------------------------

  describe 'Page load' do
    it 'loads successfully' do
      expect(page.status_code).to eq(200)
    end

    it 'greets the manager by name' do
      expect(page).to have_content('Welcome Back Kenny!')
    end
  end

  # -------------------------------------------------------------------------
  # Test the top navigation bar
  # -------------------------------------------------------------------------

  describe 'Top navigation bar' do
    it 'navigates to Adjust Loyalty when clicked' do
      within('nav') { click_link 'Adjust Loyalty' }
      expect(page).to have_current_path('/manager/adjustloyalty')
    end

    it 'navigates to View Feedback when clicked' do
      within('nav') { click_link 'View Feedback' }
      expect(page).to have_current_path('/manager/viewfeedback')
    end

    it 'navigates back to the homepage when Dashboard is clicked' do
      within('nav') { click_link 'Dashboard' }
      expect(page).to have_current_path('/manager/homepage')
    end
  end

  # -------------------------------------------------------------------------
  # Test the sidebar
  # -------------------------------------------------------------------------

  describe 'Sidebar navigation' do
    it 'navigates to the manager dashboard when View Dashboard is clicked' do
      click_link 'View Dashboard'
      expect(page).to have_current_path('/manager/homepage')
    end

    it 'navigates to the barista homepage when Step in as Barista is clicked' do
      click_link 'Step in as Barista'
      expect(page).to have_current_path('/staff/homepage')
    end

    it 'navigates to manage stock when Manage Stock is clicked' do
      click_link 'Manage Stock'
      expect(page).to have_current_path('/managestock')
    end

    it 'navigates to orders when View Orders is clicked' do
      click_link 'View Orders'
      expect(page).to have_current_path('/orders')
    end

    it 'navigates to refunds when View Refunds is clicked' do
      click_link 'View Refunds'
      expect(page).to have_current_path('/refunds')
    end

    it 'logs out when Logout is clicked' do
      click_link 'Logout'
      expect(page.current_path).to eq('/login').or eq('/')
    end
  end

  # -------------------------------------------------------------------------
  # Test the top coffees panel
  # -------------------------------------------------------------------------

  describe 'Top Coffees panel' do
    it 'renders coffee rows ranked from 1' do
      within('.glass-card', text: 'Top Coffees') do
        expect(page.first('tbody tr td')).to have_content('1')
      end
    end

    it 'displays each coffee name, price and quantity sold' do
      within('.glass-card', text: 'Top Coffees') do
        page.all('tbody tr').each do |row|
          cells = row.all('td')
          expect(cells[1].text).not_to be_empty
          expect(cells[2].text).to match(/\d/)
          expect(cells[3].text).to match(/\d/)
        end
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test the top beans panel
  # -------------------------------------------------------------------------

  describe 'Top Beans panel' do
    it 'displays the empty-state message when no beans exist' do
      within('.glass-card', text: 'Top Beans') do
        expect(page).to have_content('No Beans.')
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test the top Customers panel
  # -------------------------------------------------------------------------

  describe 'Top Customers panel' do
    it 'renders customer rows ranked from 1' do
      within('.glass-card', text: 'Top Customers') do
        expect(page.first('tbody tr td')).to have_content('1')
      end
    end

    it 'displays each customer ID, username and total spent' do
      within('.glass-card', text: 'Top Customers') do
        page.all('tbody tr').each do |row|
          cells = row.all('td')
          expect(cells[1].text).to match(/\d/)
          expect(cells[2].text).not_to be_empty
          expect(cells[3].text).to match(/\d/)
        end
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test the free Coffees Redeemed panel
  # -------------------------------------------------------------------------

  describe 'Free Coffees Redeemed panel' do
    it 'displays a numeric redeemed coffee count' do
      within('.glass-card', text: 'Free Coffees Redeemed') do
        expect(page).to have_content('Coffees have been redeemed!')
        expect(page.text).to match(/\d+/)
      end
    end
  end

  # -------------------------------------------------------------------------
  # Test the membership panel
  # -------------------------------------------------------------------------

  describe 'Membership panel' do
    it 'displays the total member count from the database' do
      expect(page).to have_content("There are #{Users.count} members in total")
    end

    it 'displays the number of new members this month' do
      expect(page).to have_content('new members this month')
    end

    it 'shows a month-on-month growth comparison or explains there is nothing to compare' do
      has_growth    = page.has_content?("of last month's growth")
      has_no_growth = page.has_content?('Last month had no new members to compare.')
      expect(has_growth || has_no_growth).to be true
    end
  end

  # -------------------------------------------------------------------------
  # Test the access control
  # -------------------------------------------------------------------------

  describe 'Access control' do
    context 'when visiting without any session' do
      before do
        Capybara.reset_sessions!
        visit '/manager/homepage'
      end

      it 'redirects to the login page' do
        expect(page.current_path).to eq('/login')
      end
    end
  end
end