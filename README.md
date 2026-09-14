# Badly Brewed Coffee — Management & Customer Platform

A web-based software interface built for **Badly Brewed Coffee**, providing tools for administrators, staff, and customers to manage daily operations, orders, and internal workflows.

---

## Overview

This project is a full-stack e-commerce and point-of-sale platform built with Ruby and Sinatra. It implements role-based access control to serve four distinct user types—Customers, Staff, Managers, and Admins. The system handles the complete order lifecycle, from customer browsing and checkout to staff order fulfillment, while providing management with tools for inventory control, refund processing, and sales metric tracking.

---

## Features

### For Admins
- View all transactions
- Manage accounts
- View and delete user feedbacks

### For Staff
- Create and manage customer orders
- Process transactions
- View product availability
- Add, delete, and manage products

### For Customers
- Browse products
- Place orders
- Receive order confirmations
- Leave feedback and request refunds

### For the Manager
- Add, delete, and manage products
- Accept and decline refunds
- View product availability
- View order history
- View sales metrics for the business

---

## Installation

### 1. Download the project
```bash
git clone [https://git.shefcompsci.org.uk/com1001-2025-26/team22/project.git](https://git.shefcompsci.org.uk/com1001-2025-26/team22/project.git)
cd project/bbc/
```

### 2. Install dependencies
```bash
bundle install
```

### 3. Start the server
```bash
sinatra
```

---

## Running the Software

If you have already installed the dependencies, you can start the application locally:

```bash
cd project/bbc/
bundle install
sinatra
```
Once the server is running, navigate to http://127.0.0.1:456/ in your web browser.

---

## Running Tests

This project uses RSpec for testing. To run the test suite:

```bash
bundle install
cd project/bbc/spec
```

### Run all tests
```bash
rspec spec
```

### Run specific tests
```bash
rspec spec/acceptance
rspec spec/controller
```

---

## Account Access

You can log in to the platform using the following test credentials to explore different role permissions:

| User Type | Username | Password |
| :--- | :--- | :--- |
| Customer | User123! | User123! |
| Barista | Staff123! | Staff123! |
| Manager (Kenny) | Manager123! | Manager123! |
| Admin | Admin123! | Admin123! |
