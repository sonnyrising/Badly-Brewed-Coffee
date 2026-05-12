RSpec.describe "When visiting GET" do
  let(:admin_session) { { 'rack.session' => { user_id: 1, uname: 'admin' } } }

  context "/admin/views/manager" do
    it "verifies the return page" do
      post "/admin/views/manager", {}, admin_session

      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("http://example.org/manager/homepage")
    end
  end
end