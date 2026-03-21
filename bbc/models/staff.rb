class Staff < Sequel::Model (:Staff)
  def self.GetStaffID(username)
      staffId = Staff.where(Username: "#{username}").get(:StaffId)
      return staffId
  end

  def self.GetUsername(staffId)
    return Staff.where(StaffId: staffId).get(:StaffUsername)
  end

    def self.GetEmail(staffId)
      return Staff.where(StaffId: staffId).get(:StaffEmail)
    end
end
