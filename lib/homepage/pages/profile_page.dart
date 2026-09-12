import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/profile_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not logged in.');
      final userData = await fetchUserData(userId);

      // If user is a provider, fetch provider details as well
      if (userData['role'] == 'provider') {
        try {
          final providerDoc = await FirebaseFirestore.instance
              .collection('providers')
              .doc(userId)
              .get();
          if (providerDoc.exists && providerDoc.data() != null) {
            userData.addAll(providerDoc.data()!);
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          userProfile = userData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);

    final isProvider = userProfile?['role'] == 'provider' ||
        userProfile?['provider'] == 'true';
    final name = (userProfile?['name'] as String?)?.trim().isNotEmpty == true
        ? userProfile!['name'] as String
        : (userProfile?['username'] as String? ?? 'User');
    final imageUrl = userProfile?['imageUrl'] as String? ?? '';
    final avatarRadius = r.wp(12).clamp(40.0, 60.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const SplachScreenLoader(message: 'Loading profile...')
          : errorMessage.isNotEmpty
              ? AppErrorState(
                  message: errorMessage,
                  onRetry: _loadUserData,
                )
              : FadeInUp(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.horizontalPadding,
                      vertical: 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl) as ImageProvider
                                        : const AssetImage(AppAssets.defaultAvatar),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    name,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontSize: r.sp(22),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isProvider
                                        ? 'I am a service provider'
                                        : 'I am a service requester',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: r.sp(14),
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ProfileSection(
                              title: 'Email',
                              value: userProfile?['email'] ?? 'N/A',
                              icon: Icons.email_outlined,
                            ),
                            if (isProvider) ...[
                              ProfileSection(
                                title: 'Main Service',
                                value: userProfile?['mainService'] ?? 'N/A',
                                icon: Icons.category_outlined,
                              ),
                              ProfileSection(
                                title: 'Experience',
                                value: userProfile?['experienceLevel'] ??
                                    userProfile?['experience'] ??
                                    'N/A',
                                icon: Icons.work_outline_rounded,
                              ),
                              ProfileSection(
                                title: 'About Me',
                                value: userProfile?['aboutMe'] ??
                                    userProfile?['otherInfo'] ??
                                    'N/A',
                                icon: Icons.info_outline_rounded,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Sub Services:',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: r.sp(18),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...(userProfile?['subServices'] as List<dynamic>? ??
                                      [])
                                  .map<Widget>((service) => ListTile(
                                        leading: Icon(Icons.check_circle_rounded,
                                            color: theme.colorScheme.primary),
                                        title: Text(
                                          service.toString(),
                                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: r.sp(15)),
                                        ),
                                      )),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, r.hp(6).clamp(48.0, 56.0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                              ),
                              child: Text(
                                'Return Home',
                                style: TextStyle(
                                  fontSize: r.sp(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
