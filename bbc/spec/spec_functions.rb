def spec_before
  Feedbacks.dataset.delete
  Transactions.dataset.delete
  Users.dataset.delete
  Products.dataset.delete

  Products.insert(
    ProductId:          1,
    ProductName:        "Old Coffee",
    StockQuantity:      10,
    Price:              10.00,
    ProductImage:       "old.jpg",
    ProductDescription: "Old desc",
    Origin:             "Brazil",
    Roast:              "Medium",
    Bean:               false
  )

  Products.insert(
    ProductId:          2,
    ProductName:        "Spare Blend",
    StockQuantity:      5,
    Price:              5.00,
    ProductImage:       "spare.jpg",
    ProductDescription: "Spare desc",
    Origin:             "Colombia",
    Roast:              "Light",
    Bean:               false
  )

  Users.insert(
    UserId:          1,
    Username:        "testuser",
    LoyaltyDiscount: 0,
    LoyaltyPoints:   0,
    Suspended:       false
  )

  Transactions.insert(
    TransactionId:   1,
    UserId:          1,
    TotalCost:       10.00,
    TransactionDate: "2024-01-15",
    Status:          "Pending",
    RefundRequested: false,
    Refunded:        false
  )

  Transactions.insert(
    TransactionId:   2,
    UserId:          1,
    TotalCost:       15.00,
    TransactionDate: "2024-02-20",
    Status:          "Pending",
    RefundRequested: true,
    Refunded:        false
  )

  Feedbacks.insert(
    FeedbackId:    1,
    UserId:        1,
    TransactionId: 2,
    IssueContent:  "General issue",
    RefundReason:  "Cold coffee",
    RefundRequest: true,
    TicketNumber:  1001
  )
end