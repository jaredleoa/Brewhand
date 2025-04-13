-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables (in reverse order of dependencies)
DROP TABLE IF EXISTS public.brew_history;
DROP TABLE IF EXISTS public.user_stats;
DROP TABLE IF EXISTS public.profiles;
DROP TABLE IF EXISTS public.brew_posts;
DROP TABLE IF EXISTS public.coffee_regions;

-- Create profiles table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  favorite_brew TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create user_stats table
CREATE TABLE public.user_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  coffee_streak INTEGER DEFAULT 0,
  coffees_made INTEGER DEFAULT 0,
  unique_drinks INTEGER DEFAULT 0,
  unique_beans INTEGER DEFAULT 0,
  beans_used TEXT[] DEFAULT '{}',
  methods_used TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create brew_history table
CREATE TABLE public.brew_history (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  brew_method TEXT NOT NULL,
  bean_type TEXT NOT NULL,
  grind_size TEXT NOT NULL,
  water_amount NUMERIC NOT NULL,
  coffee_amount NUMERIC NOT NULL,
  brew_date TIMESTAMP WITH TIME ZONE NOT NULL,
  rating INTEGER,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create brew_posts table
CREATE TABLE public.brew_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  brew_method TEXT,
  bean_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Create coffee_regions table
CREATE TABLE public.coffee_regions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  country TEXT NOT NULL,
  description TEXT,
  flavor_profile TEXT,
  altitude TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brew_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brew_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coffee_regions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for profiles
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Create RLS policies for user_stats
CREATE POLICY "Users can view their own stats"
  ON public.user_stats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stats"
  ON public.user_stats FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stats"
  ON public.user_stats FOR UPDATE
  USING (auth.uid() = user_id);

-- Create RLS policies for brew_history
CREATE POLICY "Users can view their own brew history"
  ON public.brew_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own brew history"
  ON public.brew_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own brew history"
  ON public.brew_history FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own brew history"
  ON public.brew_history FOR DELETE
  USING (auth.uid() = user_id);

-- Create RLS policies for brew_posts
CREATE POLICY "Brew posts are viewable by everyone"
  ON public.brew_posts FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own brew posts"
  ON public.brew_posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own brew posts"
  ON public.brew_posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own brew posts"
  ON public.brew_posts FOR DELETE
  USING (auth.uid() = user_id);

-- Create RLS policies for coffee_regions
CREATE POLICY "Coffee regions are viewable by everyone"
  ON public.coffee_regions FOR SELECT
  USING (true);

-- Only allow authorized users (admins) to modify coffee regions
-- You'll need to implement admin functionality separately
CREATE POLICY "Only admins can insert coffee regions"
  ON public.coffee_regions FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE username = 'admin'));

CREATE POLICY "Only admins can update coffee regions"
  ON public.coffee_regions FOR UPDATE
  USING (auth.uid() IN (SELECT id FROM public.profiles WHERE username = 'admin'));

CREATE POLICY "Only admins can delete coffee regions"
  ON public.coffee_regions FOR DELETE
  USING (auth.uid() IN (SELECT id FROM public.profiles WHERE username = 'admin'));
