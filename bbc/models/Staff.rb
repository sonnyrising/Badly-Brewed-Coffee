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

  def self.validate_password(hashed_password, plain_password)
    begin
      bcrypt_password = BCrypt::Password.new(hashed_password) == plain_password
    rescue BCrypt::Errors::InvalidHash
      false
    end
  end

  def self.ComparePassword(staffId, password)
    database_password = Staff.where(staffId: staffId).get(:StaffPasswordHash)
    if validate_password(database_password, password)
      return true
    else
      return false
    end
  end

  def load(params)
    self.Username = params.fetch("uname","").strip
    self.Email = params.fetch("email","").strip
    self.PassHash = params.fetch("pword","").strip
  end
   
  def compareUsername(username)
    users = Users.all
    users.each do |user|
      return true if username == user.Username
    end
    return false
   end
end