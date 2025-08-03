-- Helper function to insert users into auth.users
CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

-- Insert sample carousel items
INSERT INTO carousel_items (title, subtitle, image_url, action_url, display_order) VALUES
('Dagligvarer', 'Leveret til din dør på ingen tid', 'carousel/groceries_banner.jpg', '/groceries', 1),
('Fresh Ingredients', 'Directly from local farms', 'carousel/fresh_ingredients.jpg', '/ingredients', 2),
('Chef Specials', 'Curated meals by top chefs', 'carousel/chef_specials.jpg', '/specials', 3),
('Weekend Deals', 'Special offers for the weekend', 'carousel/weekend_deals.jpg', '/deals', 4),
('Organic Selection', 'Premium organic products', 'carousel/organic_selection.jpg', '/organic', 5);

-- Insert sample users
INSERT INTO users (id, email, full_name) VALUES
((select insert_user_to_auth('chef1@example.com', 'password123')), 'chef1@example.com', 'Marco Rossi'),
((select insert_user_to_auth('chef2@example.com', 'password123')), 'chef2@example.com', 'Sophie Laurent'),
((select insert_user_to_auth('chef3@example.com', 'password123')), 'chef3@example.com', 'Hiroshi Tanaka');

-- Insert sample chefs
INSERT INTO chefs (user_id, name, specialties, rating, total_orders, is_available, bio) VALUES
((SELECT id FROM users WHERE email = 'chef1@example.com'), 'Marco Rossi', ARRAY['Italian', 'Mediterranean'], 4.9, 156, true, 'Passionate Italian chef with 15 years of experience'),
((SELECT id FROM users WHERE email = 'chef2@example.com'), 'Sophie Laurent', ARRAY['French', 'Pastry'], 4.8, 203, true, 'French culinary expert specializing in fine dining'),
((SELECT id FROM users WHERE email = 'chef3@example.com'), 'Hiroshi Tanaka', ARRAY['Japanese', 'Sushi'], 4.9, 189, false, 'Master sushi chef trained in Tokyo');