-- Create brew_posts table
CREATE TABLE public.brew_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  post_date TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  brew_method TEXT NOT NULL,
  bean_type TEXT NOT NULL,
  grind_size TEXT NOT NULL,
  water_amount INTEGER NOT NULL,
  coffee_amount INTEGER NOT NULL,
  likes INTEGER DEFAULT 0,
  comments TEXT[] DEFAULT '{}',
  image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Add RLS Policies
ALTER TABLE public.brew_posts ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing all posts (public)
CREATE POLICY "Anyone can view posts" 
  ON brew_posts FOR SELECT 
  USING (true);

-- Create policy for inserting own posts
CREATE POLICY "Users can insert their own posts" 
  ON brew_posts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create policy for updating own posts
CREATE POLICY "Users can update their own posts" 
  ON brew_posts FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create policy for deleting own posts
CREATE POLICY "Users can delete their own posts" 
  ON brew_posts FOR DELETE 
  USING (auth.uid() = user_id);
