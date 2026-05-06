class Feedbacks < Sequel::Model
    def self.get_feedback_quantity
      return Feedbacks.count
    end

    def self.get_issue_content(feedback_id)
      issue_content = Feedbacks.where(FeedbackId: feedback_id).get(:IssueContent)
      return issue_content
    end

    def self.get_refund_request(feedback_id)
      refund_req = Feedbacks.where(FeedbackId: feedback_id).get(:RefundRequest)
      return refund_req
    end

    def self.get_refund_reason(feedback_id)
      refund_reason = Feedbacks.where(FeedbackId: feedback_id).get(:RefundReason)
      return refund_reason
    end

    def self.get_ticket_number(feedback_id)
      ticket_num = Feedbacks.where(FeedbackId: feedback_id).get(:TicketNumber)
      return ticket_num
    end

    def load(params)
      self.IssueContent = params.fetch("issue","").strip
      self.RefundRequest = params.fetch("request","")
      self.RefundReason = params.fetch("reason","").strip
      self.TransactionId = params.fetch("transaction_id","").strip

      #Transactions.where(TransactionId: self.TransactionId).update(RefundRequested: true)

      
      #only generates a ticket number if RefundRequest == "Yes"
      if self.RefundRequest == "Yes"
        loop do
          new_ticket_num = rand(1000..9999)
          break self.TicketNumber = new_ticket_num if Feedbacks.where(TicketNumber: new_ticket_num).empty?
        end 
      else
        self.TicketNumber = nil
      end
   end

end