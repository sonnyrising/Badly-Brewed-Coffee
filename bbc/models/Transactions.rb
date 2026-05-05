class Transactions < Sequel::Model
  def load(params)
    self.UserId = params.fetch("userId", "")
    self.TotalCost = params.fetch("totalcost", "")
    self.Address = params.fetch("address", "")
    self.TransactionDate = 0
    self.Status = "Pending"
    self.RefundRequested = false
  end


  def totalsales(currentDate)
    totalsales = 0
    totalsales += Transactions.where(TransactionDate: currentDate).get(:TotalCost)
    return totalsales
  end
end