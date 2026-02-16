-- JT Gadgets Store - Supabase Database Setup
-- Run this SQL in your Supabase SQL Editor to create the required tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (linked to auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  icon_url TEXT,
  description TEXT,
  product_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  discount_price DECIMAL(10, 2),
  image_url TEXT NOT NULL,
  images TEXT[] DEFAULT '{}',
  category TEXT NOT NULL,
  brand TEXT NOT NULL,
  rating DECIMAL(2, 1) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  stock INTEGER DEFAULT 0,
  specifications JSONB,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  total_amount DECIMAL(10, 2) NOT NULL,
  shipping_address TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Policies for categories (public read)
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (true);

-- Policies for products (public read)
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

-- Policies for cart_items
CREATE POLICY "Users can view their own cart items" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cart items" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cart items" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cart items" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- Policies for orders
CREATE POLICY "Users can view their own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policies for order_items
CREATE POLICY "Users can view their own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own order items" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
  );

-- Insert sample categories
INSERT INTO categories (name, icon_url, description, product_count) VALUES
  ('Smartphones', 'smartphone', 'Latest smartphones from top brands', 45),
  ('Laptops', 'laptop', 'Powerful laptops for work and gaming', 32),
  ('Tablets', 'tablet', 'Tablets for productivity and entertainment', 18),
  ('Audio', 'headphones', 'Premium audio equipment', 67),
  ('Wearables', 'watch', 'Smartwatches and fitness trackers', 24),
  ('Gaming', 'gamepad', 'Gaming consoles and accessories', 38),
  ('Accessories', 'cable', 'Cables, chargers, and more', 156),
  ('Cameras', 'camera', 'Digital cameras and accessories', 21)
ON CONFLICT (name) DO NOTHING;

-- Insert sample products
INSERT INTO products (name, description, price, discount_price, image_url, category, brand, rating, review_count, stock, is_featured) VALUES
  ('iPhone 15 Pro Max', 'The most advanced iPhone ever with A17 Pro chip, titanium design, and 48MP camera system.', 1199.99, 1099.99, 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400', 'Smartphones', 'Apple', 4.9, 2543, 50, true),
  ('MacBook Pro 16"', 'Supercharged by M3 Pro or M3 Max chip for exceptional performance.', 2499.99, NULL, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400', 'Laptops', 'Apple', 4.8, 1876, 30, true),
  ('Sony WH-1000XM5', 'Industry-leading noise cancellation with exceptional sound quality.', 399.99, 349.99, 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?w=400', 'Audio', 'Sony', 4.7, 3421, 100, true),
  ('Samsung Galaxy S24 Ultra', 'Experience Galaxy AI with the most powerful Galaxy smartphone.', 1299.99, NULL, 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400', 'Smartphones', 'Samsung', 4.8, 1923, 45, true),
  ('iPad Pro 12.9"', 'The ultimate iPad experience with M2 chip and stunning Liquid Retina XDR display.', 1099.99, 999.99, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400', 'Tablets', 'Apple', 4.9, 2156, 35, true),
  ('PlayStation 5', 'Experience lightning-fast loading with an ultra-high speed SSD.', 499.99, NULL, 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=400', 'Gaming', 'Sony', 4.9, 5432, 20, true),
  ('Apple Watch Ultra 2', 'The most rugged and capable Apple Watch for exploration and adventure.', 799.99, NULL, 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400', 'Wearables', 'Apple', 4.8, 876, 60, false),
  ('Dell XPS 15', 'Premium ultrabook with InfinityEdge display and powerful performance.', 1799.99, 1599.99, 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400', 'Laptops', 'Dell', 4.6, 1234, 25, false);

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
