import 'package:animate_do/animate_do.dart';
import 'service.dart';
import 'package:flutter/material.dart';
import '../module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class SelectService extends StatefulWidget {
  const SelectService({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectServiceState();
  }
}

class _SelectServiceState extends State<SelectService> {
  List<Service> services = [
    Service('Home Maintenance',
        'https://img.icons8.com/3d-fluency/94/home-automation.png'),
    Service('Appliance Repair',
        'https://img.icons8.com/3d-fluency/94/maintenance.png'),
    Service('Technology & IT',
        'https://img.icons8.com/3d-fluency/94/workstation.png'),
    Service('Personal & Lifestyle',
        'https://img.icons8.com/3d-fluency/94/welfare.png'),
    Service('Educational & Tutoring',
        'https://img.icons8.com/3d-fluency/94/reading.png'),
    Service(
        'Event Support', 'https://img.icons8.com/3d-fluency/94/confetti.png'),
    Service('Cleaning',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
  ];

  int selectedService = -1;

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: selectedService >= 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/service${selectedService + 1}");
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
                        'What service do you offer?',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: r.sp(28),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select the primary category of your services',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: r.sp(14),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    final isSelected = selectedService == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedService == index) {
            selectedService = -1;
            sharedData.remove('mainService');
          } else {
            selectedService = index;
            sharedData['mainService'] = name;
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
