PRAGMA foreign_keys = ON;

CREATE TABLE Users(
  UserId INTEGER PRIMARY KEY,
  Username TEXT,
  PassHash TEXT,
  Email TEXT,
  LoyaltyPoints INTEGER,
  DaysSinceLastUse INTEGER
);

CREATE TABLE Transactions(
  TransactionId INTEGER PRIMARY KEY,
  UserId INTEGER,
  ProductId INTEGER,
  OrderId INTEGER,
  Quantity INTEGER,
  ItemPrice FLOAT,
  PaymentStatus TEXT,
  FOREIGN KEY (UserId) REFERENCES Users(UserId),
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
  FOREIGN KEY (OrderId) REFERENCES Basket(OrderId)
);

CREATE TABLE Feedbacks(
  FeedbackId INTEGER PRIMARY KEY,
  UserId INTEGER,
  Content TEXT,
  TicketNumber INTEGER,
  FOREIGN KEY (UserId) REFERENCES Users(UserId)
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
  OrderId INTEGER, 
  UserId INTEGER,
  ProductName TEXT,
  Price FLOAT, 
  Quantity INTEGER,
  OrderStatus TEXT
);