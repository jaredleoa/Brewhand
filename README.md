# BrewHand

<img src="assets/images/logo.svg" alt="BrewHand Logo" width="150"/>

BrewHand is a comprehensive mobile application for coffee enthusiasts to track, share, and discover coffee brewing experiences. The app combines personal brewing history with social features, creating a community-driven platform for coffee lovers.

## Features

### My Brews
- **Personal Profile**: Customize your profile with avatar and favorite coffee preferences
- **Brewing History**: Track and view your coffee brewing sessions
- **User Stats**: Monitor your coffee streak, total coffees made, and unique drinks tried
- **Social Integration**: Follow other coffee enthusiasts and view their profiles

### Brew Master
- **Brewing Guides**: Step-by-step instructions for various brewing methods
- **Coffee Bean Information**: Details about different coffee origins and flavor profiles
- **Brewing Parameters**: Recommendations for grind size, water temperature, and brewing time

### BrewBot
- **AI-Powered Recommendations**: Get personalized coffee brewing suggestions
- **Brewing Assistance**: Receive help with brewing techniques and troubleshooting

### Brew Social
- **Coffee Posts**: Share your brewing experiences with the community
- **Interaction**: Like, comment, and follow other users
- **Discover**: Find new coffee enthusiasts to follow

## Technologies

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter applications
- **SVG Graphics**: Vector graphics for UI elements

### Backend
- **Supabase**: Backend-as-a-Service platform
  - Authentication
  - PostgreSQL Database
  - Storage for user avatars and images
  - Row Level Security (RLS) for data protection

### Key Packages
- **image_picker**: For selecting profile images
- **path_provider**: For handling file paths
- **uuid**: For generating unique identifiers
- **flutter_svg**: For rendering SVG graphics

## Database Structure

The app uses several key data models:

- **BrewHistory**: Records of coffee brewing sessions
- **UserStats**: User activity statistics
- **BrewPost**: Social posts shared by users
- **UserProfile**: User account information
- **CoffeeRegion**: Information about coffee origins

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or Xcode (for mobile deployment)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/brewhand.git
   cd brewhand
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Run the SQL scripts in the following order:
     - `supabase_fixed_solution.sql` (complete database setup)
     - Or individual components:
       - Table creation scripts
       - `supabase_functions_fixed.sql`
       - `supabase_rls_policies.sql`
   - Update the Supabase credentials in the app

4. **Run the app**
   ```bash
   flutter run
   ```

## Contributing

Contributions to BrewHand are welcome! Please feel free to submit pull requests, create issues, or suggest new features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
