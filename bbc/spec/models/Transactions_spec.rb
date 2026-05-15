# frozen_string_literal: true

require_relative '../spec_helper'

#------- Transactions Model Tests ---------#

RSpec.describe 'Transactions Management,' do

  describe "load(params)" do
    let(:transaction) { Transactions.new }

    it "correctly assigns each field" do

      params = {
        'userId'  => 1,
        'totalcost' => 10.00,
        'address' => '67, Test Street'
      }

      transaction.load(params)
      expect(transaction.UserId).to eq(1)
      expect(transaction.TotalCost.to_f).to eq(10.0)
      expect(transaction.Address).to eq('67, Test Street')
    end
  end

  describe "totalsales(currentDate)" do
    it "returns 0 if no sales exists on the given date" do
      expect(Transactions.get_total_sales(24032026)).to eq(0)
    end

    it "correctly sums up total sales on a specific date" do
      Transactions.dataset.delete
      Transactions.insert(TransactionDate: 24032026, TotalCost: 10.00)
      Transactions.insert(TransactionDate: 24032026, TotalCost: 20.00)
      Transactions.insert(TransactionDate: 25032026, TotalCost: 10.00)

      result = Transactions.get_total_sales(24032026)
      expect(result).to eq(30.00)
    end
  end
end
