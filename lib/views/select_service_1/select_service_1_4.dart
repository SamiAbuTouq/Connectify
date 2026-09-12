import 'package:animate_do/animate_do.dart';
import 'package:connectify/views/service.dart';
import 'package:connectify/module/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class SelectService14 extends StatefulWidget {
  const SelectService14({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectServiceState();
  }
}

class _SelectServiceState extends State<SelectService14> {
  List<Service> services = [
    Service(
        'Salon at Home', 'https://img.icons8.com/3d-fluency/94/barbershop.png'),
    Service('Massage at Home',
        'https://img.icons8.com/emoji/96/person-getting-massage.png'),
    Service('Pet Care', 'https://img.icons8.com/fluency/96/cat-caregivers.png'),
    Service('Tailoring & Alterations',
        'https://img.icons8.com/fluency/96/sewing-machine.png'),
  ];

  Set<int> selectedServices = {};

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: selectedServices.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                sharedData['subServices'] = selectedServices
                    .map((index) => services[index].name)
                    .toList();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.grey800
                                    : AppColors.grey100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 52,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              "Account Created",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Welcome aboard! Your service provider account is now live. Start connecting with seekers today!",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await storeUserInfo(context);
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        "/providerDashboard",
                                        (route) => false,
                                      );
                                    }
                                  } catch (_) {
                                    // Error already shown as SnackBar inside storeUserInfo().
                                  }
                                },
                                child: const Text(
                                  "Go to Dashboard",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2,
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 22,
              ),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: FadeInUp(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: r.hp(8),
                    right: r.horizontalPadding,
                    left: r.horizontalPadding,
                    bottom: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick your sub-services',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: r.sp(28),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose the specific services you can deliver',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: r.sp(14),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(r.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: r.gridColumns,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: 80 * index),
                      child: serviceContainer(
                        services[index].imageURL,
                        services[index].name,
                        index,
                        isDark,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget serviceContainer(String image, String name, int index, bool isDark) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final iconHeight = r.hp(8).clamp(50.0, 80.0);
    final isSelected = selectedServices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedServices.contains(index)) {
            selectedServices.remove(index);
          } else {
            selectedServices.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.grey900 : AppColors.grey100)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isSelected
              ? (isDark ? AppShadows.darkSubtle : AppShadows.subtle)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(image, height: iconHeight),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: r.sp(14),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
