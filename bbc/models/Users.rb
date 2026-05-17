# frozen_string_literal: true

class Users < Sequel::Model
  def self.GetUserId(username)
    Users.where(Username: username.to_s).get(:UserId)
  end

  def self.GetUsername(userId)
    Users.where(UserId: userId).get(:Username)
  end

  def self.GetEmail(userId)
    Users.where(UserId: userId).get(:Email)
  end

  def self.GetInactivity(userId)
    Users.where(UserId: userId).get(:DaysSinceLastUse)
  end

  def self.validate_password(hashed_password, plain_password)
    BCrypt::Password.new(hashed_password) == plain_password
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def self.ComparePassword(userId, password)
    database_password = Users.where(UserId: userId).get(:PassHash)
    return true if validate_password(database_password, password)


    false
  end

  def self.get_loyalty_points(userId)
    Users.where(UserId: userId).get(:LoyaltyPoints)
  end

  def self.SetLoyaltyPoints(userId, offset)
    current_points = Users.where(UserId: userId).get(:LoyaltyPoints) || 0
    new_total = current_points + offset.to_i
    Users.where(UserId: userId).update(LoyaltyPoints: new_total)
    new_total
  end

  def self.GetTransactionHistory(_userId)
    false
  end

  def self.SetDaysSinceLastUse(userId)
    Users.where(UserId: userId).update(DaysSinceLastUse: 0)
  end

  def self.is_on_warning?(userId)
    return true if Users.where(UserId: userId).get(:Warning) == 1


    false
  end

  def self.isSuspended?(userId)
    return true if Users.where(UserId: userId).get(:Suspended) == 1


    false
  end

  def self.get_days_since_warning(userId)
    Users.where(UserId: userId).get(:DaysSinceWarning)
  end

  def self.set_days_since_warning(userId)
    Users.where(UserId: userId).update(DaysSinceWarning: 0)
  end

  def self.acc_suspension(userId)
    Users.where(UserId: userId).update(Warning: 1, DaysSinceWarning: 0)
  end

  def self.daily_acc_activity_check
    Users.where(Warning: 1, DaysSinceWarning: 5).update(Suspended: 1, Warning: 0)
    Users.where(DaysSinceLastUse: 180).update(Warning: 1, DaysSinceWarning: 0)

    Users.where(Suspended: 0).update(DaysSinceLastUse: Sequel[:DaysSinceLastUse] + 1)
    Users.where(Warning: 1).update(DaysSinceWarning: Sequel[:DaysSinceWarning] + 1) 
  end

  def load(params)
    self.Username = params.fetch('uname', '').strip
    self.Email = params.fetch('email', '').strip
    self.PassHash = BCrypt::Password.create(params.fetch('pword', '').strip)
    self.LoyaltyPoints = 0
    self.DaysSinceLastUse = 0
    self.DateJoined = Date.today.to_s
    self.AccountType = "user"
  end

  def compareUsername(username)
    users = Users.all
    users.each do |user|
      return true if username == user.Username
    end
    false
  end


  def self.beanLoyaltyPointIncrease(userId)
    points = Users.where(UserId: userId).get(:LoyaltyPoints)
    newpoints = points.to_i + 3
    Users.where(UserId: userId).update(LoyaltyPoints: newpoints)
  end

  def self.coffeeLoyaltyPointIncrease(userId)
    points = Users.where(UserId: userId).get(:LoyaltyPoints)
    newpoints = points.to_i + 1
    Users.where(UserId: userId).update(LoyaltyPoints: newpoints)
  end

  def self.pointsRedeemed(userId)
    points = Users.where(UserId: userId).get(:LoyaltyPoints)
    Users.where(UserId: userId).update(LoyaltyPoints: points - 10)
  end

  def self.manualPointsAdd(userId, newpoints)
    Users.where(UserId: userId).update(LoyaltyPoints: newpoints)
  end
end
