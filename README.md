  # Badly Brewed Coffee — Management & Customer Platform

  A web-based software interface built for **Badly Brewed Coffee**, providing tools for administrators, staff, and customers to manage daily operations, orders, and internal workflows.

  ---

  ## Overview

  Badly Brewed Coffee needs a lightweight, fast, and maintainable system to support:

  - Staff order management  
  - Admin transaction and product control  
  - Customer-facing purchase and refund interfaces

  ---

  ## Features

  ### For Admins
  - View all transactions
  - Add, edit, and delete products
  - Manage staff accounts
  - Access reporting tools

  ### For Staff
  - Create and manage customer orders
  - Process transactions
  - View product availability

  ### For Customers
  - Browse products
  - Place orders (if enabled)
  - Receive order confirmations

  ---

  ## Technology Stack

  | Component | Description |
  |----------|-------------|
  | **Sinatra** | Lightweight Ruby web framework used for routing and views |
  | **Puma** | High-performance Ruby web server |
  | **Rack** | Middleware layer connecting Sinatra to Puma |
  | **Sequel** | Database toolkit for interacting with SQL databases |
  | **ERB** | Templating engine for rendering HTML views |

  ---

  ## Installation & Setup

  ### 1. Clone the repository
  > git clone https://github.com/yourusername/badly-brewed-coffee.git
  > cd badly-brewed-coffee

  ### 2. Install dependencies
  > bundle install

  ### 4. Start the server
  Using Puma:
  > puma
  Or with rack:
  > rackup

  ## Account access

  This section is about to be written.