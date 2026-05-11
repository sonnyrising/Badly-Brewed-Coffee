require_relative '../../spec_helper'

# =============================================================================
# Simulating account view
# =============================================================================
RSpec.describe "Simulating account view" do

  let(:admin_session)   { { 'rack.session' => { user_id: 1, uname: 'admin' } } }

  accounts_viewing_routes = [
    "/admin/views/manager",
    "/admin/views/barista",
    "/admin/views/user"
  ]

  accounts_viewing_routes.each do |route|
    describe "POST #{route}" do

      context "viewing accounts" do
        it "viewing as other roles' (barista, manager, user)" do
          post route, {}, admin_session
          expect(last_response.status).to eq(302)
          expect(last_response.location).not_to eq("http://example.org/")
        end
      end
    end
  end
end