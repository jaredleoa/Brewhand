-- Create brew_history table
CREATE TABLE public.brew_history (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  brew_method TEXT NOT NULL,
  bean_type TEXT NOT NULL,
  grind_size TEXT NOT NULL,
  water_amount INTEGER NOT NULL,
  coffee_amount INTEGER NOT NULL,
  brew_date TIMESTAMP WITH TIME ZONE NOT NULL,
  rating INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Add RLS Policies
ALTER TABLE public.brew_history ENABLE ROW LEVEL SECURITY;

-- Create policy for selecting own brew history
CREATE POLICY "Users can view their own brew history" 
  ON brew_history FOR SELECT 
  USING (auth.uid() = user_id);

-- Create policy for inserting own brew history
CREATE POLICY "Users can insert their own brew history" 
  ON brew_history FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create policy for updating own brew history
CREATE POLICY "Users can update their own brew history" 
  ON brew_history FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create policy for deleting own brew history
CREATE POLICY "Users can delete their own brew history" 
  ON brew_history FOR DELETE 
  USING (auth.uid() = user_id);
