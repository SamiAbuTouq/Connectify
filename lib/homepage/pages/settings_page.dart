import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_service.dart';
import '../widgets/dialogs.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'F1',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              FadeInUp(
                child: _buildSectionHeader('Account'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 50),
                child: _buildTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'View and update your profile info',
                  onTap: () {
                    Navigator.pushNamed(context, '/profilePage');
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _buildTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Send a password reset email',
                  onTap: _handleChangePassword,
                ),
              ),

              const Divider(height: 32),

              // Preferences Section
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: _buildSectionHeader('Preferences'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: SwitchListTile(
                  secondary: Icon(Icons.notifications_outlined,
                      color: Colors.blue.shade400),
                  title: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  subtitle: Text(
                    'Receive booking updates and reminders',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  value: _notificationsEnabled,
                  activeColor: Colors.blue,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                ),
              ),

              const Divider(height: 32),

              // Support Section
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: _buildSectionHeader('Support'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Chat with us or send an email',
                  onTap: () {
                    Navigator.pushNamed(context, '/helpSupportPage');
                  },
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: _buildTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: _showAboutDialog,
                ),
              ),

              const Divider(height: 32),

              // Danger Zone
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildSectionHeader('Danger Zone'),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 450),
                child: _buildTile(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and data',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: _handleDeleteAccount,
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: () => showLogoutDialog(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blue.shade400),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.grey.shade900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 14, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Future<void> _handleChangePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email associated with this account.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.handshake, color: Colors.blue, size: 28),
            const SizedBox(width: 10),
            const Text(
              'Connectify',
              style: TextStyle(fontFamily: 'F1', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Text(
              'Connectify is a service marketplace that connects you with trusted local service providers for home maintenance, cleaning, tutoring, and more.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent. All your data, bookings, and profile information will be deleted. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete bookings
      final bookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (final doc in bookings.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await user.delete();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error: ${e.message ?? "Please re-login and try again."}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
