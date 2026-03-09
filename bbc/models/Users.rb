class Users < Sequel::Model

    def self.GetUserId(username)
        userId = Users.where(Username: "#{username}").get(:UserId)
        return userId
    end

    def self.ComparePassword(userId, password)
      database_password = Users.where(UserID: userId).get(:PassHash)
      if password == database_password
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

end