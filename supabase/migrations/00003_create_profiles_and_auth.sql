/*
# Create Profiles Table and Authentication System

## 1. User Roles
- `admin`: Full access to all system features including user management
- `medico`: Access to appointments, medical records, prescriptions
- `recepcionista`: Access to patients, appointments, payments

## 2. New Tables

### `profiles` (User Profiles)
- `id` (uuid, primary key, references auth.users)
- `username` (text, unique, username for login)
- `nome_completo` (text, full name)
- `telefone` (text, phone)
- `email` (text, email from auth)
- `role` (user_role, default: 'recepcionista', not null)
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

## 3. Security
- Enable RLS on `profiles` table
- Create admin helper function to check user role
- Add policy for admins to have full access to all profiles
- Add policy for users to read their own profile
- Add policy for users to update their own profile without changing role
- First registered user automatically becomes admin

## 4. Trigger
- Create trigger to automatically create profile when user is confirmed in auth.users
- First user gets admin role, subsequent users get recepcionista role

## 5. Notes
- This is an internal clinic system where staff need appropriate access levels
- Admins can manage all users and data
- Doctors can access medical information
- Receptionists can manage appointments and payments
*/

-- Create user role enum
CREATE TYPE user_role AS ENUM ('admin', 'medico', 'recepcionista');

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE,
  nome_completo text,
  telefone text,
  email text,
  role user_role DEFAULT 'recepcionista'::user_role NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(uid uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = uid AND p.role = 'admin'::user_role
  );
$$;

-- Create helper function to get current user role
CREATE OR REPLACE FUNCTION get_user_role(uid uuid)
RETURNS user_role
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT role FROM profiles WHERE id = uid;
$$;

-- RLS Policies for profiles
CREATE POLICY "Admins have full access to profiles" ON profiles
  FOR ALL TO authenticated USING (is_admin(auth.uid()));

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT TO authenticated USING (auth.uid() = id);

CREATE POLICY "Users can update own profile without changing role" ON profiles
  FOR UPDATE TO authenticated 
  USING (auth.uid() = id) 
  WITH CHECK (auth.uid() = id AND role = (SELECT role FROM profiles WHERE id = auth.uid()));

-- Create trigger function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  user_count int;
  extracted_username text;
BEGIN
  -- Only insert into profiles after user is confirmed
  IF OLD IS DISTINCT FROM NULL AND OLD.confirmed_at IS NULL AND NEW.confirmed_at IS NOT NULL THEN
    -- Count existing users in profiles
    SELECT COUNT(*) INTO user_count FROM profiles;
    
    -- Extract username from email (remove @miaoda.com suffix)
    extracted_username := CASE 
      WHEN NEW.email LIKE '%@miaoda.com' THEN 
        SUBSTRING(NEW.email FROM '^(.+)@miaoda\.com$')
      ELSE 
        SPLIT_PART(NEW.email, '@', 1)
    END;
    
    -- Insert into profiles, first user gets admin role
    INSERT INTO profiles (id, username, email, telefone, role)
    VALUES (
      NEW.id,
      extracted_username,
      NEW.email,
      NEW.phone,
      CASE WHEN user_count = 0 THEN 'admin'::user_role ELSE 'recepcionista'::user_role END
    );
  END IF;
  RETURN NEW;
END;
$$;

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_confirmed ON auth.users;
CREATE TRIGGER on_auth_user_confirmed
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Add updated_at trigger to profiles
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);