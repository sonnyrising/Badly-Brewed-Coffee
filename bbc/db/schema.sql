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
  Quantity FLOAT,
  TotalCost FLOAT,
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
  Price FLOAT,
  StockQuantity INTEGER
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

CREATE TABLE Coffees (
  Price FLOAT,
  CoffeeSize TEXT, 
  MilkType TEXT,
  FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE,
  FOREIGN KEY (ProductName) REFERENCES Products(ProductName) ON DELETE CASCADE,
  FOREIGN KEY (ProductImage) REFERENCES Products(ProductImage) ON DELETE CASCADE,
  FOREIGN KEY (ProductDescription) REFERENCES Products(ProductDescription) ON DELETE CASCADE,

)