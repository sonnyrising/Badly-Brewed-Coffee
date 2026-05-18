# frozen_string_literal: true

def spec_before
  Feedbacks.dataset.delete
  Basket.dataset.delete
  Transactions.dataset.delete
  Users.dataset.delete
  Products.dataset.delete

  Products.insert(
    ProductId: 1,
    ProductName: 'Old Coffee',
    StockQuantity: 10,
    Price: 10.00,
    ProductImage: 'old.jpg',
    ProductDescription: 'Old desc',
    Origin: 'Brazil',
    Roast: 'Medium',
    Bean: false
  )

  Products.insert(
    ProductId: 2,
    ProductName: 'Blend',
    StockQuantity: 5,
    Price: 5.00,
    ProductImage: 'blend.jpg',
    ProductDescription: 'blend desc',
    Origin: 'Colombia',
    Roast: 'Light',
    Bean: false
  )

  Users.insert(
    UserId: 1,
    Username: 'testuser',
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'user'
  )

  Users.insert(
    UserId: 3,
    Username: 'test',
    PassHash: BCrypt::Password.create('password'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'user'
  )

  Users.insert(
    UserId: 6,
    Username: 'User123!',
    PassHash: BCrypt::Password.create('User123!'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'user'
  )

  Users.insert(
    UserId: 2,
    Username: 'Manager123!',
    PassHash: BCrypt::Password.create('Manager123!'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'manager'
  )

  Users.insert(
    UserId: 4,
    Username: 'Staff123!',
    PassHash: BCrypt::Password.create('Staff123!'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'staff'
  )

  Users.insert(
    UserId: 5,
    Username: 'Admin',
    PassHash: BCrypt::Password.create('Admin123!'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: false,
    AccountType: 'admin'
  )
  
  Users.insert(
    UserId: 7,
    Username: 'Suspended',
    PassHash: BCrypt::Password.create('Suspended!'),
    LoyaltyDiscount: 0,
    LoyaltyPoints: 0,
    Suspended: true,
    AccountType: 'user'
  )


  Transactions.insert(
    TransactionId: 1,
    UserId: 1,
    TotalCost: 10.00,
    TransactionDate: '2024-01-15',
    Status: 'Pending',
    RefundRequested: false,
    Refunded: false
  )

  Transactions.insert(
    TransactionId: 2,
    UserId: 1,
    TotalCost: 15.00,
    TransactionDate: '2024-02-20',
    Status: 'Pending',
    RefundRequested: true,
    Refunded: false
  )

  Feedbacks.insert(
    FeedbackId: 1,
    UserId: 1,
    TransactionId: 2,
    IssueContent: 'General issue',
    RefundReason: 'Cold coffee',
    RefundRequest: true,
    TicketNumber: 1001
  )

end
