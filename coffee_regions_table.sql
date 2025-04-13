-- Create coffee_regions reference table
CREATE TABLE public.coffee_regions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  region_name TEXT NOT NULL UNIQUE,
  flavor_notes TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- This is a reference table so we'll make it publicly readable
ALTER TABLE public.coffee_regions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view coffee regions" 
  ON coffee_regions FOR SELECT 
  USING (true);
  
-- Only admins can modify the reference data (you'll need to set this up)
