import '/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/services/auth_service.dart';
import 'package:connectify/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential == null) {
        return; // User canceled
      }

      // Save user info to Firestore
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': user.displayName ?? 'Anonymous',
          'email': user.email,
          'image_url': user.photoURL,
        }, SetOptions(merge: true));

        // Save FCM device token
        await NotificationService.instance.saveUserToken(user.uid);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/homePage");
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final buttonHeight = r.hp(6.5).clamp(48.0, 56.0);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.formMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      const Logo(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Login",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: r.sp(32),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Get started with your account",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: r.sp(14),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        validator: (value) => value!.isEmpty
                            ? "Email cannot be empty."
                            : null,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: "Email",
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                          labelText: "Password",
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: buttonHeight,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_forward),
                          iconAlignment: IconAlignment.end,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              AuthService()
                                  .loginWithEmail(_emailController.text,
                                      _passwordController.text)
                                  .then(
                                (value) async {
                                  if (value == "Login Successful") {
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      await NotificationService.instance.saveUserToken(uid);
                                    }
                                    if (!context.mounted) return;
                                    Navigator.restorablePushNamedAndRemoveUntil(
                                      context,
                                      "/",
                                      (route) => false,
                                    );
                                  } else {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value),
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                          label: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: r.sp(15),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: buttonHeight,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _handleGoogleSignIn,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/logo/google.png",
                                width: r.sp(20),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: r.sp(15),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/signup",
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
