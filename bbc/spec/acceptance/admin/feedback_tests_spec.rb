RSpec.describe 'When managing feedback' do

  context 'while an admin is logged in' do

    it 'it shows feedback details' do
      login_as_admin
      user = Users.create(Username: 'test_name', Email: 'test@test.com')
      feedback = Feedbacks.create(
        UserId: user.UserId,
        IssueContent: "This is a test feedback submission"
      )

      visit '/admin/feedback'

      expect(page).to have_current_path('/admin/feedback')
      expect(page).to have_content("This is a test feedback submission")
    end

    it 'it deletes a feedback entry from the database' do
      login_as_admin
      user = Users.create(Username: 'test_name', Email: 'test@test.com')
      feedback = Feedbacks.create(
          UserId: user.UserId,
          IssueContent: "This is a test feedback submission"
      )

      visit '/admin/feedback'

      find(:xpath, "//form[input[@value='#{feedback.FeedbackId}'] and @action='/admin/feedback/delete']//button").click


      expect(page).to have_current_path('/admin/feedback')
      expect(Feedbacks[feedback.FeedbackId]).to be_nil
    end
  end
end