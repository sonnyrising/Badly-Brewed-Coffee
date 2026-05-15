# frozen_string_literal: true

RSpec.describe 'Deleting an account' do
  it 'deletes the account and associated data' do
    account = Users.create(
      Username: 'alice',
      Email: 'alice@example.com',
      LoyaltyPoints: 100,
      DaysSinceLastUse: 3
    )

    Transactions.insert(
      UserId: account.UserId,
      TotalCost: 49.99,
      TransactionDate: '01012024',
      TransactionId: 1000
    )

    Feedbacks.create(UserId: account.UserId, IssueContent: 'hi')
    Basket.create(UserId: account.UserId)

    login_as_admin

    visit "/admin/accounts"

    find(:xpath, "//form[input[@value='#{account.UserId}'] and @action='/admin/accounts/delete']//button").click

    expect(page).to have_current_path('/admin/accounts')
    expect(Users[account.UserId]).to be_nil
    expect(Transactions.where(UserId: account.UserId).count).to eq(0)
    expect(Feedbacks.where(UserId: account.UserId).count).to eq(0)
    expect(Basket.where(UserId: account.UserId).count).to eq(0)
  end
end
