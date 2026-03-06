PRAGMA foreign_keys = ON;

CREATE TABLE Users(
  UserId INTEGER PRIMARY KEY,
  Username TEXT,
  Pass TEXT,
  Email TEXT,
  LoyaltyPoints INTEGER
);

CREATE TABLE Transactions(
  TransactionId INTEGER PRIMARY KEY,
  UserId INTEGER,
  ProductId INTEGER,
  OrderId INTEGER,
  FOREIGN KEY (UserId) REFERENCES Users(UserId),
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE TABLE Feedbacks(
  FeedbackId INTEGER PRIMARY KEY,
  UserId INTEGER,
  Content TEXT,
  FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE Products(
  ProductId INTEGER PRIMARY KEY,
  ProductName TEXT,
  Price FLOAT,
  StockQuantity INTEGER
);
