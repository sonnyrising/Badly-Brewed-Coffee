class Feedbacks < Sequel::Model

    def self.GetFeedbackQuantity
      return Feedbacks.count
    end

    def self.GetIssueContent(feedbackId)
      issue_content = Feedbacks.where(FeedbackId: feedbackId).get(:IssueContent)
      return issue_content
    end

    def self.GetRefundRequest(feedbackId)
      refund_req = Feedbacks.where(FeedbackId: feedbackId).get(:RefundRequest)
      return refund_req
    end

    def self.GetRefundReason(feedbackId)
      refund_reason = Feedbacks.where(FeedbackId: feedbackId).get(:RefundReason)
      return refund_reason
    end

    def self.GetTicketNumber(feedbackId)
      ticket_num = Feedbacks.where(FeedbackId: feedbackId).get(:TicketNumber)
      return ticket_num
    end

    def load(params)
      self.IssueContent = params.fetch("issue","").strip
      self.RefundRequest = params.fetch("request","").strip
      self.RefundReason = params.fetch("reason","").strip
      self.TicketNumber = rand(1000..9999)
   end

end