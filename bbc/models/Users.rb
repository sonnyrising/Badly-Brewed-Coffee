class Users < Sequel::Model

    def GetUserId(Username)
        userId = Users.where(Username: "#{Username}").get(:id)
        return userId
    end

    def GetLoyaltyPoints(userId)
        numberOfPoints = Users.where(UserId: userId).get(:LoyaltyPoints)
        return numberOfPoints
    end

    def SetLoyaltyPoints(userId, offset)
        Users.where(UserId: userId).update(LoyaltyPoints: Sequel[:LoyaltyPoints] + offset)
    end

    def GetTransactionHistory(userId)
        return false
    end

end