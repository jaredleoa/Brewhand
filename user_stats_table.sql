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

-- Add RLS Policies
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Create policy for selecting own stats
CREATE POLICY "Users can view their own stats" 
  ON user_stats FOR SELECT 
  USING (auth.uid() = user_id);

-- Create policy for inserting own stats
CREATE POLICY "Users can insert their own stats" 
  ON user_stats FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create policy for updating own stats
CREATE POLICY "Users can update their own stats" 
  ON user_stats FOR UPDATE 
  USING (auth.uid() = user_id);
