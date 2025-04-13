import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brewhand/services/supabase_service.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({Key? key}) : super(key: key);

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController(); // Changed from displayName to fullName
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = false;
  final SupabaseService _supabaseService = SupabaseService();
  
  String? _favoriteBrew; // Combined favorite order/bean into a single field
  
  final List<String> _favoriteBrews = [
    'Espresso',
    'Americano',
    'Cappuccino',
    'Latte',
    'Flat White',
    'Pour Over (Ethiopia)',
    'French Press (Colombia)',
    'Cold Brew',
    'Aeropress (Kenya)',
    'V60 (Ethiopia)',
    'Chemex (Costa Rica)',
    'Moka Pot (Brazil)',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    
    setState(() {
      _isCheckingUsername = true;
    });
    
    try {
      _isUsernameAvailable = await _supabaseService.isUsernameAvailable(username);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking username: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _supabaseService.createUserProfile(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim().isNotEmpty 
            ? _fullNameController.text.trim() 
            : null,
        avatarUrl: null,
        bio: null,
        favoriteBrew: _favoriteBrew,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to the home page
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF3E1F00);
    final Color cardColor = Color(0xFF59300C);
    final Color brightOrange = Color(0xFFFFB74D);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Set Up Your Profile', 
          style: TextStyle(
            color: brightOrange,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brew Profile Header with Gradient
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          brightOrange.withOpacity(0.2),
                          brightOrange.withOpacity(0.4)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/coffee_cup.svg',
                              width: 40,
                              height: 40,
                              colorFilter: ColorFilter.mode(brightOrange, BlendMode.srcIn),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Brew Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tell us about your coffee preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Username Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Username',
                          style: TextStyle(
                            color: brightOrange,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Choose a unique username',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: Colors.transparent,
                            suffixIcon: _isCheckingUsername
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(
                                      color: brightOrange,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : _usernameController.text.isNotEmpty
                                    ? Icon(
                                        _isUsernameAvailable
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: _isUsernameAvailable
                                            ? Colors.green
                                            : Colors.red,
                                      )
                                    : null,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _checkUsernameAvailability();
                            } else {
                              setState(() {
                                _isCheckingUsername = false;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!_isUsernameAvailable) {
                              return 'This username is already taken';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Full Name Field (Optional)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6, top: 12),
                        child: Text(
                          'Full Name (optional)',
                          style: TextStyle(
                            color: brightOrange,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextFormField(
                          controller: _fullNameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'How others will see you',
                            hintStyle: TextStyle(color: Colors.white30),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Favorite Brew
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6, top: 12),
                        child: Text(
                          'Favorite Coffee Brew',
                          style: TextStyle(
                            color: brightOrange,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: cardColor,
                            style: TextStyle(color: Colors.white),
                            value: _favoriteBrew,
                            isExpanded: true,
                            hint: Text(
                              'Select your favorite brew',
                              style: TextStyle(color: Colors.white30),
                            ),
                            icon: Icon(Icons.arrow_drop_down, color: brightOrange),
                            items: _favoriteBrews.map((brew) {
                              return DropdownMenuItem(
                                value: brew,
                                child: Text(brew),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _favoriteBrew = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Create Profile Button
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: brightOrange))
                      : ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brightOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Create Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
