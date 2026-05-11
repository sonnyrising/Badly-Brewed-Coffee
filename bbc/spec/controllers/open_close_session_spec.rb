# =============================================================================
# Open and Close Session Tests
# =============================================================================

RSpec.describe "Open and Close Session Tests" do

  let(:manager_session) { { 'rack.session' => { user_id: 1, uname: 'manager' } } }

  describe "GET /landingpage" do
    context "when visiting the landing page" do
      it "returns 200" do
        get "/landingpage"
        expect(last_response.status).to eq(200)
      end

      it "clears the session" do
        get "/landingpage", {}, user_session
        expect(last_request.env['rack.session'][:userId]).to be_nil
      end
    end
  end

  describe "GET /" do
    context "when visiting the root path" do
      it "redirects to /landingpage" do
        get "/"
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include("/landingpage")
      end

      it "clears the session before redirecting" do
        get "/", {}, user_session
        expect(last_request.env['rack.session'][:userId]).to be_nil
      end
    end
  end
end