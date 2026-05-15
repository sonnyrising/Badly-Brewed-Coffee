# frozen_string_literal: true

require_relative '../spec_helper'

#------- Feedback Model Tests ---------#

RSpec.describe 'Feedbacks Management,' do

  describe ".get_feedback_quantity" do
    it "it gets the number of feedbacks in the database" do
      Feedbacks.dataset.delete
      Feedbacks.insert(FeedbackId: 1)

      total = Feedbacks.get_feedback_quantity
      expect(total).to eq(1)
    end
  end

  describe ".get_issue_content" do
    it "retrieves correct issue content for a given feedback ID" do
      Feedbacks.dataset.delete
      target_id = Feedbacks.insert(FeedbackId: 1, IssueContent: 'test issue')
      content = Feedbacks.get_issue_content(target_id)

      expect(content).to eq('test issue')
    end

    it "returns nil if entry doesn't exist" do
      content = Feedbacks.get_issue_content(909)
      expect(content).to be_nil
    end
  end

  describe ".get_refund_request" do
    it "retrieves correct refund request for a given feedback ID" do
      Feedbacks.dataset.delete
      target_id = Feedbacks.insert(FeedbackId: 1, RefundRequest: 'true')
      content = Feedbacks.get_refund_request(target_id)

      expect(content).to eq('true')
    end

    it "returns nil if entry doesn't exist" do
      content = Feedbacks.get_refund_request(909)
      expect(content).to be_nil
    end
  end

  describe ".get_refund_reason" do
    it "retrieves correct refund reason for a given feedback ID" do
      Feedbacks.dataset.delete
      target_id = Feedbacks.insert(FeedbackId: 1, RefundRequest: 'true', RefundReason: 'test reason')
      content = Feedbacks.get_refund_reason(target_id)

      expect(content).to eq('test reason')
    end

    it "returns nil if entry doesn't exist" do
      content = Feedbacks.get_refund_reason(909)
      expect(content).to be_nil
    end
  end

  describe ".get_ticket_number" do
    it "retrieves correct refund ticket number for a given feedback ID" do
      Feedbacks.dataset.delete
      target_id = Feedbacks.insert(FeedbackId: 1, RefundRequest: 'true', TicketNumber: 1001)
      content = Feedbacks.get_ticket_number(target_id)

      expect(content).to eq(1001)
    end

    it "returns nil if entry doesn't exist" do
      content = Feedbacks.get_refund_request(909)
      expect(content).to be_nil
    end
  end

  describe ".get_refund_request" do
    it "retrieves correct refund request for a given feedback ID" do
      Feedbacks.dataset.delete
      target_id = Feedbacks.insert(FeedbackId: 1, RefundRequest: 'true')
      content = Feedbacks.get_refund_request(target_id)

      expect(content).to eq('true')
    end

    it "returns nil if entry doesn't exist" do
      content = Feedbacks.get_refund_request(909)
      expect(content).to be_nil
    end
  end

  describe "load(params)" do
    let(:feedback) { Feedbacks.new }

    it "correctly assigns fields and strips the whitespace" do
      params = {
        'issue'   => ' Test Coffee',
        'request' => 'No',
        'reason'  => ' Test reason   ',
        'transaction_id'  => '120'
      }

      feedback.load(params)
      expect(feedback.IssueContent).to eq('Test Coffee')
      expect(feedback.RefundRequest).to eq('No')
      expect(feedback.RefundReason).to eq('Test reason')
      expect(feedback.TransactionId).to eq('120')
      expect(feedback.TicketNumber).to be_nil
    end

    context "when a refund is requested," do
      it "it generates a random ticket number between 1000 to 9999" do
        params = { 'request'  =>  'Yes' }
        feedback.load(params)
        expect(feedback.TicketNumber).to be_between(1000, 9999)
      end

      it "it ensures the ticket number generated is unique" do
        Feedbacks.dataset.delete
        Feedbacks.insert(FeedbackId: 20, TicketNumber: 2026)

        allow(feedback).to receive(:rand).and_return(2026, 3026)
        feedback.load({ 'request' => 'Yes'})
        
        expect(feedback.TicketNumber).to eq(3026)
      end
    end
  

    context "Transactions Table" do
      it "updates the transaction status when loaded" do
        mock_query = double('query')
        allow(Transactions).to receive(:where).with(TransactionId: '120').and_return(mock_query)
        expect(mock_query).to receive(:update).with(RefundRequested: true)

        params = { 'transaction_id' => '120', 'request' => 'Yes' }
        feedback.load(params)
      end
    end
  end
end

      
