class Feedbacks < Sequel::Model

    def GetFeedbackQuantity
        return Feedbacks.count
    end

    def GetFeedbackContent(feedbackId)
        return Feedbacks.where(FeedbackId: feedbackId).get(:Content)
    end

end