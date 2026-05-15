RSpec.describe 'When managing views' do

  context 'while an admin is logged in' do

    it 'it shows customer view' do
      login_as_admin

      visit '/admin/views'

      find(:xpath, "//form[@action='/admin/views/user']//button").click

      expect(page).to have_current_path('/user/homepage')
    end

    it 'it shows staff view' do
      login_as_admin

      visit '/admin/views'

      find(:xpath, "//form[@action='/admin/views/barista']//button").click

      expect(page).to have_current_path('/staff/homepage')
    end

    it 'it shows manager view' do
      login_as_admin

      visit '/admin/views'

      find(:xpath, "//form[@action='/admin/views/manager']//button").click

      expect(page).to have_current_path('/manager/homepage')
    end
  end
end