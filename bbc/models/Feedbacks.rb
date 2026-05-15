# frozen_string_literal: true

class Feedbacks < Sequel::Model
  def self.get_feedback_quantity
    Feedbacks.count
  end

  def self.get_issue_content(feedback_id)
    Feedbacks.where(FeedbackId: feedback_id).get(:IssueContent)
  end

  def self.get_refund_request(feedback_id)
    Feedbacks.where(FeedbackId: feedback_id).get(:RefundRequest)
  end

  def self.get_refund_reason(feedback_id)
    Feedbacks.where(FeedbackId: feedback_id).get(:RefundReason)
  end

  def self.get_ticket_number(feedback_id)
    Feedbacks.where(FeedbackId: feedback_id).get(:TicketNumber)
  end

  def load(params)
    self.IssueContent = params.fetch('issue', '').strip
    self.RefundRequest = params.fetch('request', '')
    self.RefundReason = params.fetch('reason', '').strip
    self.TransactionId = params.fetch('transaction_id', '').strip

    Transactions.where(TransactionId: self.TransactionId).update(RefundRequested: true)


    # only generates a ticket number if RefundRequest == "Yes"
    if self.RefundRequest == 'Yes'
      loop do
        new_ticket_num = rand(1000..9999)
        break self.TicketNumber = new_ticket_num if Feedbacks.where(TicketNumber: new_ticket_num).empty?
      end
    else
      self.TicketNumber = nil
    end
  end
end
