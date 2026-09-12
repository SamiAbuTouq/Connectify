import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/services/auth_service.dart';
import '/widgets/logo.dart';
import '../module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reenterPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isReenterPasswordVisible = false;

  Future<void> _handleGoogleSignUp() async {
    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential == null) {
        return; // User canceled
      }
      final user = userCredential.user;
      if (user != null) {
        sharedData['email'] = user.email ?? '';
        sharedData['password'] = _passwordController.text;
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/uploadPhoto");
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-up failed: $error')),
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
                        "Sign Up",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: r.sp(32),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Create a new account and get started",
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
                        validator: (value) => value!.length < 8
                            ? "Password should have at least 8 characters."
                            : null,
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        validator: (value) =>
                            value != _passwordController.text
                                ? "Passwords do not match."
                                : null,
                        controller: _reenterPasswordController,
                        obscureText: !_isReenterPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          labelText: "Re-enter Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isReenterPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _isReenterPasswordVisible =
                                    !_isReenterPasswordVisible;
                              });
                            },
                          ),
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
                                  .createAccountWithEmail(
                                      _emailController.text,
                                      _passwordController.text)
                                  .then(
                                (value) {
                                  if (value == "Account Created") {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      sharedData['email'] = user.email ?? '';
                                      sharedData['password'] =
                                          _passwordController.text;
                                    }
                                    if (!context.mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      "/uploadPhoto",
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
                            "Sign Up",
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
                          onPressed: _handleGoogleSignUp,
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
                                "Sign up with Google",
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
                            "Already have an account?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/login",
                              );
                            },
                            child: const Text(
                              "Login",
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
