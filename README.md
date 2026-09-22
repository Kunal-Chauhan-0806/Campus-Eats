# 🔥 CampusEats — College Canteen Ordering System

> **Pure Java** (no Spring Boot, no frameworks) + **MySQL** + **HTML/CSS/JavaScript**

---

## 📁 Project Structure

```
canteen/
│
├── static/
│   └── index.html              ← Full frontend (Login, Signup, Menu, Cart, Orders)
│
├── schema.sql                  ← MySQL schema + 30 menu items + sample users
│
├── run.sh                      ← Linux/Mac build & run script
├── run.bat                     ← Windows build & run script
│
├── lib/
│   └── mysql-connector-j-*.jar ← (you download this — see step 2)
│
└── src/com/college/canteen/
    │
    ├── server/
    │   ├── Main.java               ← Entry point — starts Java HttpServer on port 8080
    │   └── StaticFileHandler.java  ← Serves static HTML/CSS/JS
    │
    ├── controller/
    │   ├── AuthController.java     ← POST /api/auth/signup  &  POST /api/auth/login
    │   ├── MenuController.java     ← GET  /api/menu
    │   └── OrderController.java    ← POST/GET/PUT /api/orders
    │
    ├── dao/
    │   ├── UserDAO.java            ← JDBC operations for users (signup, login, find)
    │   ├── MenuDAO.java            ← JDBC operations for food items
    │   └── OrderDAO.java           ← JDBC operations for orders (with transactions)
    │
    ├── model/
    │   ├── User.java               ← Student user model
    │   ├── FoodItem.java           ← Menu item model
    │   ├── Order.java              ← Order model
    │   └── OrderItem.java          ← Line item model
    │
    └── util/
        ├── DBConnection.java       ← JDBC connection (update DB credentials here)
        └── HttpUtil.java           ← JSON helpers, HTTP response helpers, parser
```

---

## 🚀 Setup Instructions

### Step 1 — Install Java 17+
Download from https://adoptium.net/ and install.
Verify: `java -version`

### Step 2 — Download MySQL JDBC Driver
1. Go to https://dev.mysql.com/downloads/connector/j/
2. Select **Platform Independent** → download the ZIP
3. Extract and copy `mysql-connector-j-X.X.X.jar` into the `lib/` folder

### Step 3 — Setup MySQL Database
Open MySQL Workbench or terminal:

```sql
-- Create DB and user
CREATE DATABASE canteen_db CHARACTER SET utf8mb4;
CREATE USER 'canteen_user'@'localhost' IDENTIFIED BY 'canteen123';
GRANT ALL PRIVILEGES ON canteen_db.* TO 'canteen_user'@'localhost';
FLUSH PRIVILEGES;
```

Then run the schema file to create tables and seed all 30 menu items:

```bash
mysql -u canteen_user -p canteen_db < schema.sql
```

### Step 4 — Configure DB Credentials (if needed)
Edit `src/com/college/canteen/util/DBConnection.java`:

```java
private static final String DB_URL  = "jdbc:mysql://localhost:3306/canteen_db?...";
private static final String DB_USER = "canteen_user";
private static final String DB_PASS = "canteen123";
```

### Step 5 — Build & Run

**Linux / Mac:**
```bash
chmod +x run.sh
./run.sh
```

**Windows:**
```
run.bat
```

**Manually:**
```bash
mkdir out
javac -cp lib/mysql-connector-j-*.jar -d out $(find src -name "*.java")
java -cp "out:lib/mysql-connector-j-*.jar" com.college.canteen.server.Main
```

### Step 6 — Open in Browser
```
http://localhost:8080
```

---

## 🔑 Demo Login Credentials

| Name         | Roll Number | Password    |
|--------------|-------------|-------------|
| Rahul Sharma | CS2024001   | password123 |
| Priya Mehta  | IT2024012   | password123 |
| Arjun Nair   | ME2024045   | password123 |

---

## 🍽️ Cuisine Counters

| Counter   | Cuisine          | 5 Items |
|-----------|------------------|---------|
| Counter A | South Indian     | Masala Dosa, Idli Sambar, Medu Vada, Ven Pongal, Uttapam |
| Counter B | North Indian     | Butter Paneer, Dal Makhani, Chole Bhature, Aloo Paratha, Rajma Chawal |
| Counter C | Chinese          | Veg Fried Rice, Hakka Noodles, Manchurian, Spring Rolls, Chilli Paneer |
| Counter D | Mumbai Specials  | Vada Pav, Pav Bhaji, Misal Pav, Bhel Puri, Sev Puri |
| Counter E | Italian          | Margherita Pizza, Arrabbiata Pasta, Bruschetta, Veg Lasagna, Garlic Bread |
| Counter F | Western          | Classic Burger, French Fries, Grilled Sandwich, Mac & Cheese, Caesar Salad |

---

## 🌐 REST API Endpoints

| Method | URL                          | Description                     |
|--------|------------------------------|---------------------------------|
| POST   | `/api/auth/signup`           | Register new student account    |
| POST   | `/api/auth/login`            | Login with roll + password      |
| GET    | `/api/menu`                  | Get all available menu items    |
| GET    | `/api/menu?cuisine=Chinese`  | Filter by cuisine               |
| POST   | `/api/orders`                | Place a new order               |
| GET    | `/api/orders?userId=1`       | Get all orders for a student    |
| GET    | `/api/orders/token?token=101`| Look up order by token number   |
| PUT    | `/api/orders?id=1&status=READY` | Update order status          |

---

## ✨ Features

| Feature | Details |
|---------|---------|
| 🔐 Login / Signup | Student registration with SHA-256 password hashing |
| 🍴 6 Cuisine Counters | South Indian · North Indian · Chinese · Mumbai · Italian · Western |
| 🛒 Cart System | Add/remove/quantity control, real-time GST calculation |
| 🎫 Token System | Auto-generated token number per order |
| 📍 Counter Assignment | Each cuisine maps to a dedicated pickup counter |
| 💾 MySQL Database | All users, menu items, and orders persisted with JDBC |
| 📋 My Orders | Order history with status tracking |
| 📱 Responsive | Works on mobile & desktop |

---

## 🛠️ Technology Stack

| Layer    | Technology |
|----------|------------|
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Backend  | **Pure Java 17** — `com.sun.net.httpserver.HttpServer` |
| Database | MySQL 8.0 via **JDBC** (no ORM) |
| Auth     | SHA-256 password hashing (Java `MessageDigest`) |
| Build    | Manual `javac` / `java` — no Maven, no Gradle |

> ⚠️ Note: The `com.sun.net.httpserver` package is part of the JDK — no external dependencies needed beyond the MySQL JDBC driver.

---

*College Project — CampusEats Online Canteen Ordering System*
