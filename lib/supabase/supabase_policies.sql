-- Enable Row Level Security
ALTER TABLE carousel_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chefs ENABLE ROW LEVEL SECURITY;

-- Policies for carousel_items table
-- Allow everyone to read active carousel items
CREATE POLICY "Allow public read of active carousel items"
    ON carousel_items FOR SELECT
    USING (is_active = true);

-- Allow authenticated users to perform all operations on carousel_items
CREATE POLICY "Allow authenticated users full access to carousel_items"
    ON carousel_items FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policies for users table
-- Users can insert their own profile (for signup)
CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Users can read and update their own profile
CREATE POLICY "Users can view and update own profile"
    ON users FOR ALL
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Allow reading public user info for chefs
CREATE POLICY "Allow public read of user profiles"
    ON users FOR SELECT
    USING (true);

-- Policies for chefs table
-- Allow everyone to read chef profiles
CREATE POLICY "Allow public read of chef profiles"
    ON chefs FOR SELECT
    USING (true);

-- Allow authenticated users to perform all operations on chefs
CREATE POLICY "Allow authenticated users full access to chefs"
    ON chefs FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);