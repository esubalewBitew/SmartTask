import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:smarttask/core/theme/theme_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  Map<String, dynamic> _userSettings = {};

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      setState(() => _isLoading = true);
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userSettings = doc.data()?['settings'] ?? {};
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSettings(String key, dynamic value) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'settings.$key': value,
        });
        setState(() {
          _userSettings[key] = value;
        });
      }
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please sign in to view profile',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: null,
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.primaryColor,
                        child: Text(
                          user.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? user.email?.split('@')[0] ?? 'User',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Section
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Mode
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: GoogleFonts.poppins(),
                      ),
                      value: themeState == ThemeState.dark,
                      onChanged: (value) {
                        context.read<ThemeCubit>().toggleTheme();
                        _updateSettings('darkMode', value);
                      },
                    );
                  },
                ),

                // Notifications
                SwitchListTile(
                  title: Text(
                    'Push Notifications',
                    style: GoogleFonts.poppins(),
                  ),
                  value: _userSettings['notifications'] ?? true,
                  onChanged: (value) => _updateSettings('notifications', value),
                ),

                // Email Notifications
                SwitchListTile(
                  title: Text(
                    'Email Notifications',
                    style: GoogleFonts.poppins(),
                  ),
                  value: _userSettings['emailNotifications'] ?? true,
                  onChanged: (value) =>
                      _updateSettings('emailNotifications', value),
                ),

                const Divider(height: 32),

                // Account Section
                Text(
                  'Account',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(
                    'Change Password',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () => context.go('/auth/change-password'),
                ),

                ListTile(
                  leading: const Icon(Icons.security),
                  title: Text(
                    'Two-Factor Authentication',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () => context.go('/auth/two-factor-setup'),
                ),

                const Divider(height: 32),

                // Danger Zone
                Text(
                  'Danger Zone',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    'Delete Account',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () => _showDeleteAccountDialog(),
                ),
              ],
            ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = _auth.currentUser;
                if (user != null) {
                  // Delete user data from Firestore
                  await _firestore.collection('users').doc(user.uid).delete();
                  // Delete user account
                  await user.delete();
                  if (mounted) {
                    context.go('/auth/login');
                  }
                }
              } catch (e) {
                debugPrint('Error deleting account: $e');
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
