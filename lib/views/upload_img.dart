import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectify/widgets/user_image_picker.dart';
import 'package:connectify/services/cloudinary_service.dart';
import '../module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class UploadPhoto extends StatefulWidget {
  const UploadPhoto({super.key});

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();

    if (_selectedImage != null) {
      setState(() => _isUploading = true);
      final result = await uploadToCloudinary1(_selectedImage);
      if (!mounted) return;
      setState(() => _isUploading = false);

      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload photo. Please try again or tap Skip."),
          ),
        );
        return;
      }
    } else {
      sharedData['imageUrl'] = '';
    }

    sharedData['username'] = username;
    if (!mounted) return;
    Navigator.pushNamed(context, "/imLookingFor");
  }

  void _handleSkip() {
    if (!_formKey.currentState!.validate()) return;
    sharedData['imageUrl'] = '';
    sharedData['username'] = _usernameController.text.trim();
    Navigator.pushNamed(context, "/imLookingFor");
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final buttonHeight = r.hp(6.5).clamp(48.0, 56.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connectify',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: r.sp(20),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.formMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: r.hp(2)),
                    Text(
                      "Create Your Profile",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: r.sp(28),
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Add a photo (optional) and choose a display name",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: r.sp(14),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    UserImagePicker(
                      onPickImage: (pickedImage) {
                        setState(() {
                          _selectedImage = pickedImage;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required.';
                          } else if (value.trim().length <= 2) {
                            return 'Username must be more than 2 characters.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      height: buttonHeight,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.pureWhite,
                                ),
                              )
                            : const Icon(Icons.arrow_forward),
                        iconAlignment: IconAlignment.end,
                        onPressed: _isUploading ? null : _handleNext,
                        label: Text(
                          _isUploading ? "Uploading..." : "Next",
                          style: TextStyle(
                            fontSize: r.sp(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: buttonHeight,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isUploading ? null : _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          "Skip for now",
                          style: TextStyle(
                            fontSize: r.sp(15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: r.hp(2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
