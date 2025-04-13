-- Drop and recreate the user_stats table with the correct column names
DROP TABLE IF EXISTS public.user_stats;

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

-- Add Row Level Security (RLS) to the table
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to select their own stats
CREATE POLICY "Users can view their own stats" 
  ON user_stats FOR SELECT 
  USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own stats
CREATE POLICY "Users can insert their own stats" 
  ON user_stats FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own stats
CREATE POLICY "Users can update their own stats" 
  ON user_stats FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create policy to allow users to delete their own stats
CREATE POLICY "Users can delete their own stats" 
  ON user_stats FOR DELETE 
  USING (auth.uid() = user_id);
