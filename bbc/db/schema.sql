PRAGMA foreign_keys = ON;

CREATE TABLE Users(
  UserId INTEGER PRIMARY KEY,
  Username TEXT,
  PassHash TEXT,
  Email TEXT,
  LoyaltyPoints INTEGER,
  DaysSinceLastUse INTEGER,
  Suspended INTEGER
);

CREATE TABLE Transactions(
  TransactionId INTEGER PRIMARY KEY,
  UserId INTEGER,
  ProductId INTEGER,
  Quantity INTEGER,
  ItemPrice FLOAT,
  PaymentStatus TEXT,
  TransactionDate INTEGER,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);

CREATE TABLE Feedbacks(
  FeedbackId INTEGER PRIMARY KEY,
  UserId INTEGER,
  IssueContent TEXT,
  RefundRequest TEXT,
  RefundReason TEXT,
  TicketNumber INTEGER,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

CREATE TABLE Products(
  ProductId INTEGER PRIMARY KEY,
  ProductName TEXT,
  ProductImage TEXT,
  ProductDescription TEXT,
  Price FLOAT,
  StockQuantity INTEGER
);

CREATE TABLE Basket(
  ProductId INTEGER, 
  UserId INTEGER,
  Quantity INTEGER,
  OrderStatus TEXT,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);

CREATE TABLE Staffs(
  StaffId INTEGER,
  StaffUsername TEXT,
  StaffEmail TEXT,
  StaffPasswordHash TEXT,
  EmployeeLevel TEXT,
  EmploymentStatus INTEGER
)