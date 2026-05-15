# frozen_string_literal: true

class Transactions < Sequel::Model
  def load(params)
    self.UserId = params.fetch('userId', '')
    self.TotalCost = params.fetch('totalcost', '').to_f.round(2).to_s
    self.Address = params.fetch('address', '')
    self.TransactionDate = 0
    self.Status = 'Pending'
    self.RefundRequested = false
  end

  def self.get_total_sales(currentDate)
    totalsales = Transactions.where(TransactionDate: currentDate).sum(:TotalCost) || 0
    totalsales
  end
end
