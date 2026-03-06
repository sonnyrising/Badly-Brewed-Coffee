CREATE TABLE Users(
  UserId INTEGER PRIMARY KEY,
  Username TEXT,
  Pass TEXT,
  Email TEXT,
  LoyaltyPoints INTEGER
);

CREATE TABLE Transactions(
  TransactionId INTEGER PRIMARY KEY,
  UserId INTEGER FOREIGN KEY,
  ProductId INTEGER FOREIGN KEY,
  OrderId INTEGER
);

CREATE TABLE Feedbacks(
  FeedbackId INTEGER PRIMARY KEY,
  UserId INTEGER FOREIGN KEY,
  Content TEXT
);

CREATE TABLE Products(
  ProductId INTEGER PRIMARY KEY,
  ProductName TEXT,
  Price FLOAT,
  StockQuantity INTEGER
);