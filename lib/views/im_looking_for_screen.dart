import 'package:flutter/material.dart';
import '/widgets/select_container_widget.dart';
import '../module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class ImLookingForScreen extends StatefulWidget {
  const ImLookingForScreen({super.key});

  @override
  State<ImLookingForScreen> createState() => _ImLookingForState();
}

class _ImLookingForState extends State<ImLookingForScreen> {
  bool select1 = false;
  bool select2 = false;

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
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: r.hp(1)),
                    Text(
                      "I am a...",
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: r.sp(28),
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Choose your role to personalize your experience",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: r.sp(14),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: r.hp(3)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          select1 = true;
                          select2 = false;
                        });
                      },
                      child: SelectContainerWidget(
                        title1: 'Service Provider',
                        title2: "I offer professional services",
                        img: select1
                            ? 'assets/images/others/check.png'
                            : 'assets/images/others/uncheck.png',
                        select: select1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          select1 = false;
                          select2 = true;
                        });
                      },
                      child: SelectContainerWidget(
                        title1: "Looking For Service",
                        title2: "I am looking for home services",
                        img: select2
                            ? 'assets/images/others/check.png'
                            : 'assets/images/others/uncheck.png',
                        select: select2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        iconAlignment: IconAlignment.end,
                        onPressed: () async {
                          if (select1) {
                            sharedData['provider'] = 'true';
                            Navigator.pushNamed(context, "/experiance");
                          } else if (select2) {
                            sharedData['provider'] = 'false';
                            try {
                              await storeUserInfo(context);
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  "/homePage",
                                  (route) => false,
                                );
                              }
                            } catch (_) {
                              // Error already shown as SnackBar inside storeUserInfo().
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an option first.'),
                              ),
                            );
                          }
                        },
                        label: Text(
                          "Next",
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
