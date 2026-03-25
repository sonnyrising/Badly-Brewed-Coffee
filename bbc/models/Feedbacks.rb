class Feedbacks < Sequel::Model

    def self.get_feedback_quantity
      return Feedbacks.count
    end

    def self.get_issue_content(feedbackId)
      issue_content = Feedbacks.where(FeedbackId: feedbackId).get(:IssueContent)
      return issue_content
    end

    def self.get_refund_request(feedbackId)
      refund_req = Feedbacks.where(FeedbackId: feedbackId).get(:RefundRequest)
      return refund_req
    end

    def self.get_refund_reason(feedbackId)
      refund_reason = Feedbacks.where(FeedbackId: feedbackId).get(:RefundReason)
      return refund_reason
    end

    def self.get_ticket_number(feedbackId)
      ticket_num = Feedbacks.where(FeedbackId: feedbackId).get(:TicketNumber)
      return ticket_num
    end

    def load(params)
      self.IssueContent = params.fetch("issue","").strip
      self.RefundRequest = (params.fetch("request","") == "Yes")
      self.RefundReason = params.fetch("reason","").strip
      #only generates a ticket number if RefundRequest == "Yes"
      if self.RefundRequest
        loop do
          new_ticket_num = rand(1000..9999)
          break self.TicketNumber = new_ticket_num unless Feedbacks.where(TicketNumber: new_ticket_num).exists?
        end 
      else
        self.TicketNumber = nil
      end
   end

end