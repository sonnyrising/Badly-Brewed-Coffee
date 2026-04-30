class Users < Sequel::Model

    def self.GetUserId(username)
        userId = Users.where(Username: "#{username}").get(:UserId)
        return userId
    end

    def self.GetUsername(userId)
      return Users.where(UserId: userId).get(:Username)
    end

    def self.GetEmail(userId)
      return Users.where(UserId: userId).get(:Email)
    end

    def self.GetInactivity(userId)
      return Users.where(UserId: userId).get(:DaysSinceLastUse)
    end

    def self.validate_password(hashed_password, plain_password)
      begin
        bcrypt_password = BCrypt::Password.new(hashed_password) == plain_password
      rescue BCrypt::Errors::InvalidHash
        false
      end
    end

    def self.ComparePassword(userId, password)
      database_password = Users.where(UserID: userId).get(:PassHash)
      if validate_password(database_password, password)
        return true
      else
        return false
      end
    end
    
    def self.GetLoyaltyPoints(userId)
        numberOfPoints = Users.where(UserId: userId).get(:LoyaltyPoints)
        return numberOfPoints
    end

    def self.SetLoyaltyPoints(userId, offset)
        Users.where(UserId: userId).update(LoyaltyPoints: Sequel[:LoyaltyPoints] + offset)
    end

    def self.GetTransactionHistory(userId)
        return false
    end

    def self.GetDaysSinceLastUse(userId)
      daysSinceLastUse = Users.where(UserId: userId).get(:DaysSinceLastUse)
      return daysSinceLastUse
    end

    def self.SetDaysSinceLastUse(userId)
      Users.where(UserId: userId).update(DaysSinceLastUse: 0)
    end

    def self.is_on_warning?(userId)
      if Users.where(UserId: userId).get(:Warning) == 1
        return true
      else
        false
      end
    end

    def self.isSuspended?(userId)
      if Users.where(UserId: userId).get(:Suspended) == 1
        return true
      else
        false
      end
    end

    def self.daily_inactivity_check
      suspended = Users.where(Sequel[:DaysSinceLastUse] > 184).update(Suspended: 1) 
      on_warning = Users.where(Sequel[:DaysSinceLastUse] >= 180).update(Warning: 1)
      Users.where(Suspended: 0).update(DaysSinceLastUse: Sequel[:DaysSinceLastUse] + 1)
    end

    def load(params)
      self.Username = params.fetch("uname","").strip
      self.Email = params.fetch("email","").strip
      self.PassHash = params.fetch("pword","").strip
      self.LoyaltyPoints = 0
      self.DaysSinceLastUse = 0
   end
   
   def compareUsername(username)
    users = Users.all
    users.each do |user|
      return true if username == user.Username
    end
    return false
   end

   def self.clearGuestBasket
    Basket.where(UserId: 1).destroy
  end

  def self.beanLoyaltyPointIncrease(userId)
    points = Users.where(UserId: userId).get(:LoyaltyPoints)
    Users.where(UserId: userId).update(LoyaltyPoints: points + 3)
  end
end