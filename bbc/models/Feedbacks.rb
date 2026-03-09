class Feedbacks < Sequel::Model

    def self.GetFeedbackQuantity
        return Feedbacks.count
    end

    def self.GetFeedbackContent(feedbackId)
        return Feedbacks.where(FeedbackId: feedbackId).get(:Content)
    end

end