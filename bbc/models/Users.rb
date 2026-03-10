class Users < Sequel::Model

    def self.GetUserId(username)
        userId = Users.where(Username: "#{username}").get(:UserId)
        return userId
    end

    def self.GetUsername(userId)
      return Users.where(UserId: userId).get(:Username)
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


end