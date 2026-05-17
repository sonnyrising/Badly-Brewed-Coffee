PRAGMA foreign_keys = ON;

CREATE TABLE Users(
  UserId INTEGER PRIMARY KEY,
  Username TEXT,
  PassHash TEXT,
  Email TEXT,
  LoyaltyPoints INTEGER,
  DaysSinceLastUse INTEGER,
  DaysSinceWarning INTEGER,
  Warning INTEGER,
  Suspended INTEGER,
  FreeCoffeesRedeemed INTEGER,
  LoyaltyDiscount FLOAT,
  DateJoined TEXT,
  AccountType TEXT
);

CREATE TABLE Transactions(
  TransactionId INTEGER PRIMARY KEY,
  UserId INTEGER,
  TotalCost FLOAT,
  Address Text,
  TransactionDate INTEGER,
  Status TEXT,
  RefundRequested BOOLEAN,
  Refunded BOOLEAN,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

CREATE TABLE Feedbacks(
  FeedbackId INTEGER PRIMARY KEY,
  UserId INTEGER,
  TransactionId TEXT,
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
  Roast TEXT,
  Origin TEXT,
  Price FLOAT,
  StockQuantity INTEGER,
  Bean BOOLEAN
);

CREATE TABLE Basket(
  BasketId INTEGER PRIMARY KEY,
  TransactionId INTEGER,
  ProductId INTEGER, 
  UserId INTEGER,
  ItemId INTEGER,
  Quantity INTEGER,
  Milk TEXT,
  Size TEXT,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE,
  FOREIGN KEY (TransactionId) REFERENCES Transactions(TransactionId) ON DELETE CASCADE
);

CREATE TABLE Customisations (
  ItemId INTEGER PRIMARY KEY,
  ProductId INTEGER,
  MilkType TEXT,
  CoffeeSize TEXT,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);

CREATE TABLE Logs (
  LogId INTEGER PRIMARY KEY,
  UserId INTEGER,
  LogDate DATE,
  LogDescription TEXT,
  FOREIGN KEY (UserId) references Users(UserId) ON DELETE CASCADE
);