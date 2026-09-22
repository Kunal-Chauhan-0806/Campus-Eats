-- ════════════════════════════════════════════════════════════════
--  CampusEats — Full Database Schema
--  Run: mysql -u root -p < schema.sql
-- ════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS canteen_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE canteen_db;

-- Create a dedicated DB user (optional, recommended)
-- CREATE USER 'canteen_user'@'localhost' IDENTIFIED BY 'canteen123';
-- GRANT ALL PRIVILEGES ON canteen_db.* TO 'canteen_user'@'localhost';
-- FLUSH PRIVILEGES;

-- ── Drop existing tables ──────────────────────────────────────────────────────
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS food_items;
DROP TABLE IF EXISTS users;

-- ── TABLE: users ─────────────────────────────────────────────────────────────
CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    roll_number   VARCHAR(30)  NOT NULL UNIQUE,
    email         VARCHAR(100) NOT NULL UNIQUE,
    department    VARCHAR(80)  NOT NULL,
    password_hash VARCHAR(64)  NOT NULL,        -- SHA-256 hex (64 chars)
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_roll  (roll_number),
    INDEX idx_email (email)
);

-- ── TABLE: food_items ─────────────────────────────────────────────────────────
CREATE TABLE food_items (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL,
    description   VARCHAR(500),
    price         DECIMAL(8,2)  NOT NULL,
    cuisine_type  VARCHAR(50)   NOT NULL,
    counter_name  VARCHAR(20)   NOT NULL,
    emoji         VARCHAR(10),
    is_veg        TINYINT(1)    DEFAULT 1,
    is_available  TINYINT(1)    DEFAULT 1,
    INDEX idx_cuisine (cuisine_type)
);

-- ── TABLE: orders ─────────────────────────────────────────────────────────────
CREATE TABLE orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT           NOT NULL,
    student_name  VARCHAR(100)  NOT NULL,
    roll_number   VARCHAR(30)   NOT NULL,
    token_number  INT           NOT NULL UNIQUE,
    total_amount  DECIMAL(10,2) NOT NULL,
    status        ENUM('PENDING','PREPARING','READY','COLLECTED') DEFAULT 'PENDING',
    created_at    DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user   (user_id),
    INDEX idx_token  (token_number),
    INDEX idx_status (status)
);

-- ── TABLE: order_items ────────────────────────────────────────────────────────
CREATE TABLE order_items (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT           NOT NULL,
    food_item_id INT,
    food_name    VARCHAR(100)  NOT NULL,
    price        DECIMAL(8,2)  NOT NULL,
    quantity     INT           NOT NULL DEFAULT 1,
    counter_name VARCHAR(20)   NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order (order_id)
);

-- ════════════════════════════════════════════════════════════════
--  SEED: 6 Cuisines × 5 Items = 30 Menu Items
-- ════════════════════════════════════════════════════════════════

-- Counter A: South Indian
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Masala Dosa',  'Crispy rice crepe with spiced potato masala, sambar & chutneys',60,'South Indian','Counter A','🫓',1),
('Idli Sambar',  'Soft steamed rice cakes with tangy sambar & coconut chutney',   40,'South Indian','Counter A','🍚',1),
('Medu Vada',    'Crunchy lentil fritters with sambar & mint chutney',            35,'South Indian','Counter A','🍩',1),
('Ven Pongal',   'Rice & moong dal cooked with ghee, pepper, cumin & cashews',   50,'South Indian','Counter A','🍲',1),
('Uttapam',      'Fluffy pancake topped with onions, tomatoes & green chillies', 55,'South Indian','Counter A','🥞',1);

-- Counter B: North Indian
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Butter Paneer', 'Velvety tomato-cream curry with soft paneer, served with naan', 90,'North Indian','Counter B','🧀',1),
('Dal Makhani',   'Slow-cooked black lentils simmered overnight in butter & spices',75,'North Indian','Counter B','🫘',1),
('Chole Bhature', 'Spicy chickpea curry with two golden deep-fried bhaturas',      70,'North Indian','Counter B','🍞',1),
('Aloo Paratha',  'Stuffed wheat flatbread with spiced potato, curd & pickle',     50,'North Indian','Counter B','🫓',1),
('Rajma Chawal',  'Red kidney bean gravy over steamed basmati rice',               70,'North Indian','Counter B','🍱',1);

-- Counter C: Chinese
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Veg Fried Rice', 'Wok-tossed rice with mixed vegetables in soy & sesame oil',  80,'Chinese','Counter C','🍚',1),
('Hakka Noodles',  'Stir-fried noodles with veggies in Indo-Chinese sauce',       80,'Chinese','Counter C','🍜',1),
('Manchurian',     'Crispy veggie balls tossed in tangy, spicy Manchurian sauce', 90,'Chinese','Counter C','🥡',1),
('Spring Rolls',   'Crispy rolls stuffed with cabbage, carrot & glass noodles',   65,'Chinese','Counter C','🌯',1),
('Chilli Paneer',  'Crispy paneer tossed with capsicum, onions & chilli sauce',   95,'Chinese','Counter C','🌶️',1);

-- Counter D: Mumbai Specials
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Vada Pav',  'Mumbai burger — spiced potato vada in a pav with chutneys', 25,'Mumbai Specials','Counter D','🍔',1),
('Pav Bhaji', 'Buttery mixed veg mash with toasted pav, onion & lime',     60,'Mumbai Specials','Counter D','🍛',1),
('Misal Pav', 'Spicy sprouted curry topped with farsan, served with pav',  55,'Mumbai Specials','Counter D','🥘',1),
('Bhel Puri', 'Puffed rice chaat with sweet, tangy & spicy chutneys',      40,'Mumbai Specials','Counter D','🍿',1),
('Sev Puri',  'Crispy puris topped with potato, chutneys & sev',           40,'Mumbai Specials','Counter D','🫙',1);

-- Counter E: Italian
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Margherita Pizza', 'Classic pizza with tomato sauce, mozzarella & basil',        140,'Italian','Counter E','🍕',1),
('Arrabbiata Pasta', 'Penne in fiery tomato-garlic sauce with red chillies',       120,'Italian','Counter E','🍝',1),
('Bruschetta',       'Toasted sourdough with marinated tomatoes, garlic & olive oil', 80,'Italian','Counter E','🍞',1),
('Veg Lasagna',      'Layers of pasta, roasted veggies, béchamel & mozzarella',   160,'Italian','Counter E','🥘',1),
('Garlic Bread',     'Golden baguette with herb butter & roasted garlic',           60,'Italian','Counter E','🥖',1);

-- Counter F: Western
INSERT INTO food_items (name,description,price,cuisine_type,counter_name,emoji,is_veg) VALUES
('Classic Burger',   'Brioche bun, crispy veggie patty, cheddar & house sauce', 130,'Western','Counter F','🍔',1),
('French Fries',     'Double-fried golden fries with flaky salt & ketchup',      70,'Western','Counter F','🍟',1),
('Grilled Sandwich', 'Triple-decker pressed sandwich with cheese & chipotle mayo',90,'Western','Counter F','🥪',1),
('Mac & Cheese',     'Four-cheese macaroni baked with golden breadcrumb crust',  110,'Western','Counter F','🧀',1),
('Caesar Salad',     'Crisp romaine, Caesar dressing, parmesan & croutons',      100,'Western','Counter F','🥗',1);

-- ════════════════════════════════════════════════════════════════
--  SAMPLE DATA (demo users & orders for testing)
--  Passwords below are SHA-256 of "password123"
-- ════════════════════════════════════════════════════════════════
INSERT INTO users (first_name,last_name,roll_number,email,department,password_hash) VALUES
('Rahul',  'Sharma', 'CS2024001', 'rahul@college.edu',  'Computer Science',      'ef92b778bafe771207346c66c2bfe88e2d5d81f0f500ca37e2e3f81e4d9b1b5b'),
('Priya',  'Mehta',  'IT2024012', 'priya@college.edu',  'Information Technology','ef92b778bafe771207346c66c2bfe88e2d5d81f0f500ca37e2e3f81e4d9b1b5b'),
('Arjun',  'Nair',   'ME2024045', 'arjun@college.edu',  'Mechanical Engineering','ef92b778bafe771207346c66c2bfe88e2d5d81f0f500ca37e2e3f81e4d9b1b5b');
-- password for all sample users: password123

-- ════════════════════════════════════════════════════════════════
--  USEFUL ADMIN QUERIES
-- ════════════════════════════════════════════════════════════════
-- View pending orders:
--   SELECT o.token_number, o.student_name, oi.food_name, oi.quantity, oi.counter_name
--   FROM orders o JOIN order_items oi ON o.id = oi.order_id
--   WHERE o.status = 'PENDING' ORDER BY o.created_at;
--
-- Mark order as ready:
--   UPDATE orders SET status = 'READY' WHERE token_number = 101;
--
-- Revenue by counter today:
--   SELECT oi.counter_name, SUM(oi.price * oi.quantity) AS revenue
--   FROM order_items oi JOIN orders o ON oi.order_id = o.id
--   WHERE DATE(o.created_at) = CURDATE()
--   GROUP BY oi.counter_name ORDER BY revenue DESC;
