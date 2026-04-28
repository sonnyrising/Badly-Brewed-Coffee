class Transactions < Sequel::Model
  def load(params)
    self.UserId = params.fetch("userId", "")
    self.Quantity = params.fetch("quantity", "")
    self>Address = params.fetch("address", "")
    self.TransactionDate = 0
  end
end