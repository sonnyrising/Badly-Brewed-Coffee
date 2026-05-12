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
  DateJoined TEXT
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
  Quantity INTEGER,
  FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE,
  FOREIGN KEY (TransactionId) REFERENCES Transactions(TransactionId) ON DELETE CASCADE
);

CREATE TABLE Staff(
  StaffId INTEGER,
  StaffUsername TEXT,
  StaffPasswordHash TEXT,
  EmployeeLevel TEXT,
  EmploymentStatus TEXT
);


CREATE TABLE CoffeeSize (
  ItemID INTEGER PRIMARY KEY,
  BasketId INTEGER,
  ProductId INTEGER,
  Quantity INTEGER,
  CoffeeSize TEXT,
  FOREIGN KEY (BasketId) REFERENCES Basket(BasketId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);

CREATE TABLE MilkTypes (
  ItemID INTEGER PRIMARY KEY,
  BasketId INTEGER,
  ProductId INTEGER,
  Quantity INTEGER,
  MilkType TEXT,
  FOREIGN KEY (BasketId) REFERENCES Basket(BasketId) ON DELETE CASCADE,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);

CREATE TABLE Logs (
  LogId INTEGER PRIMARY KEY,
  UserId INTEGER,
  LogDate DATE,
  LogDescription TEXT,
  FOREIGN KEY (UserId) references Users(UserId) ON DELETE CASCADE
);