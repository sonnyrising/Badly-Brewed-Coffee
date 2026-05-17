# frozen_string_literal: true

require_relative '../spec_helper'

#========== Users Model Tests ==========#
RSpec.describe 'Users Management,' do

  context "User ID," do
    it ".GetUserId(username)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John Test')

      user_id = Users.GetUserId('John Test')
      expect(user_id).to eq(1)
    end

    it "returns nil if user entry doesn't exist" do
      user_id = Users.GetUserId('Dummy Test Name')
      expect(user_id).to be_nil
    end
  end

  context "Username," do
    it ".GetUsername(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John')

      username = Users.GetUsername(1)
      expect(username).to eq('John')
    end

    it "returns nil if user entry doesn't exist" do
      username = Users.GetUsername(999)
      expect(username).to be_nil
    end
  end

  context "Email" do
    it ".GetEmail(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', Email: 'test@test.com')

      email = Users.GetEmail(1)
      expect(email).to eq('test@test.com')
    end

    it "returns nil if entry doesn't exist" do
      email = Users.GetEmail(999)
      expect(email).to be_nil
    end
  end

  context "Inactivity," do
    it ".GetInactivity(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', DaysSinceLastUse: 5)

      inactivity = Users.GetInactivity(1)
      expect(inactivity).to eq(5)
    end

    it ".SetDaysSinceLastUse(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', DaysSinceLastUse: 10)

      Users.SetDaysSinceLastUse(1)
      updated_days = Users.where(UserId: 1).get(:DaysSinceLastUse)
      expect(updated_days).to eq(0)
    end

    it "returns nil if user entry doesn't exist" do
      inactivity = Users.GetInactivity(999)
      expect(inactivity).to be_nil
    end
  end

  context "Password" do
    let(:plain_password) { 'Password123!' }
    let(:hashed_password) { BCrypt::Password.create(plain_password) }
    it ".validate_password(hashed_password, plain_password)" do
      Users.dataset.delete
      Users.insert(UserId: 30, Username: 'John Test', PassHash: hashed_password)

      result = Users.ComparePassword(30, plain_password)
      expect(result).to be_truthy
    end

    it "returns false if password isn't valid" do
      Users.dataset.delete
      Users.insert(UserId: 30, Username: 'John Test', PassHash: hashed_password)

      result = Users.ComparePassword(30, 'WrongPassword!?')
      expect(result).to be_falsy
    end

    it "return false if user ID doesn't exist in database" do
      result = Users.ComparePassword(696, plain_password)
      expect(result).to be_falsy
    end
  end

  context "Loyalty Points," do
    it ".get_loyalty_points(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', LoyaltyPoints: 2)

      points = Users.get_loyalty_points(1)
      expect(points).to eq(2)
    end

    it "returns nil if user entry doesn't exist" do
      inactivity = Users.GetInactivity(999)
      expect(inactivity).to be_nil
    end

    it ".SetLoyaltyPoints(userId, offset)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', LoyaltyPoints: 2)
      Users.SetLoyaltyPoints(1, 2)
      new_points = Users.where(UserId: 1).get(:LoyaltyPoints)
      expect(new_points).to eq(4)
    end

    it ".beanLoyaltyPointIncrease(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', LoyaltyPoints: 0)
      Users.beanLoyaltyPointIncrease(1)
      new_points = Users.where(UserId: 1).get(:LoyaltyPoints)
      expect(new_points).to eq(3)
    end

    it ".coffeeLoyaltyPointIncrease(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', LoyaltyPoints: 0)
      Users.coffeeLoyaltyPointIncrease(1)
      new_points = Users.where(UserId: 1).get(:LoyaltyPoints)
      expect(new_points).to eq(1)
    end

    it ".pointsRedeemed(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', LoyaltyPoints: 15)
      Users.pointsRedeemed(1)
      new_points = Users.where(UserId: 1).get(:LoyaltyPoints)
      expect(new_points).to eq(5)
    end
  end

  context "Transactions History," do
    it ".GetTransactionHistory(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John')

      history = Users.GetTransactionHistory(1)
      expect(history).to be false
    end
  end

  context "Account Warning/Suspension," do
    it ".is_on_warning?(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', Warning: 1)

      warning = Users.is_on_warning?(1)
      expect(warning).to be_truthy
    end

    it "returns false if user entry isn't on warning" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', Warning: 0)

      inactivity = Users.is_on_warning?(1)
      expect(inactivity).to be_falsy
    end

    it ".isSuspended?(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', Suspended: 1)

      suspended = Users.isSuspended?(1)
      expect(suspended).to be_truthy
    end

    it "returns false if user entry isn't suspended" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', Suspended: 0)

      suspended = Users.isSuspended?(1)
      expect(suspended).to be false
    end

    it ".get_days_since_warning(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', DaysSinceWarning: 3)

      days = Users.get_days_since_warning(1)
      expect(days).to eq(3)
    end

    it ".set_days_since_warning(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', DaysSinceWarning: 3)

      Users.set_days_since_warning(1)
      days = Users.where(UserId: 1).get(:DaysSinceWarning)
      expect(days).to eq(0)
    end

    it ".acc_suspension(userId)" do
      Users.dataset.delete
      Users.insert(UserId: 1, Username: 'John', DaysSinceLastUse: 185, Warning: 0, DaysSinceWarning: 0)

      suspend = Users.acc_suspension(1)
      expect(suspend).to eq(1)
    end
  end

  context ".daily_acc_activity_check" do
    it "suspends users who have been warned for 5 days" do
      Users.dataset.delete
      Users.insert(UserId: 1, Warning: 1, DaysSinceWarning: 5, Suspended: 0)

      Users.daily_acc_activity_check
      user = Users.first(UserId: 1)
      expect(user[:Suspended]).to eq(1)
      expect(user[:Warning]).to eq(0)
    end

    it "sends warning to users who have been inactive for 6 months(180 days)" do
      Users.dataset.delete
      Users.insert(UserId: 2, DaysSinceLastUse: 180, Warning: 0, DaysSinceWarning: 0)

      Users.daily_acc_activity_check
      user = Users.first(UserId: 2)
      expect(user[:Warning]).to eq(1)
      expect(user[:DaysSinceWarning]).to eq(1)
    end

    it "increments standard inactivity and warning for all users daily" do
      Users.dataset.delete
      Users.insert(UserId: 2, DaysSinceLastUse: 10, Warning: 0, DaysSinceWarning: 0, Suspended: 0)
      Users.insert(UserId: 3, Warning: 1, Suspended: 0, DaysSinceWarning: 2)

      Users.daily_acc_activity_check
      user_2 = Users.first(UserId: 2)
      user_3 = Users.first(UserId: 3)

      expect(user_2[:DaysSinceLastUse]).to eq(11)
      expect(user_3[:DaysSinceWarning]).to eq(3)
    end
  end

  describe "load(params)" do
    let(:user_instance) { Users.new }

    it "correctly assigns fields and strips the whitespace" do
      params = {
        'uname' =>  ' Afiq Nuraldin   ',
        'email' =>  ' test@test.com',
        'pword' =>  '   passWord123?    '
      }

      user_instance.load(params)

      expect(user_instance.Username).to eq('Afiq Nuraldin')
      expect(user_instance.Email).to eq('test@test.com')

      saved_hash = BCrypt::Password.new(user_instance.PassHash)
      expect(saved_hash).to eq('passWord123?')
    end
  end

  describe "compareUsername(username)" do
    it "loops through all records and returns true if a username matches" do
      Users.dataset.delete
      Users.insert(Username: 'Alice')
      Users.insert(Username: 'John Test')
      Users.insert(Username: 'Charlie')

      user_model = Users.new
      result = user_model.compareUsername('John Test')

      expect(result).to be_truthy
    end

    it "returns false if loop completes and no usernames matched" do
      Users.dataset.delete
      Users.insert(Username: 'Alice')
      Users.insert(Username: 'John Test')

      user_model = Users.new
      result = user_model.compareUsername('Charlie')

      expect(result).to be_falsy
    end
  end
end

