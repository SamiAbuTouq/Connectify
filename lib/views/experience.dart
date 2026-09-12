import 'package:flutter/material.dart';
import '../module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class Experiance extends StatefulWidget {
  const Experiance({super.key});

  @override
  State<Experiance> createState() => _ExperianceState();
}

class _ExperianceState extends State<Experiance> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDuration;
  final TextEditingController _optionalInfoController = TextEditingController();

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
                  vertical: AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Experience",
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: r.sp(28),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Help clients understand your expertise level",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: r.sp(14),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        "Select Your Experience",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<String>(
                        value: _selectedDuration,
                        hint: Text(
                          "Select years of experience",
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(
                              value: "less than 1 Year",
                              child: Text("less than 1 Year")),
                          DropdownMenuItem(value: "1 Year", child: Text("1 Year")),
                          DropdownMenuItem(value: "2 Year", child: Text("2 Year")),
                          DropdownMenuItem(value: "3 Year", child: Text("3 Year")),
                          DropdownMenuItem(value: "4 Year", child: Text("4 Year")),
                          DropdownMenuItem(
                              value: "5 to 10 Year", child: Text("5 to 10 Year")),
                          DropdownMenuItem(value: "+10 Year", child: Text("+10 Year")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDuration = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a duration.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More information (Optional)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _optionalInfoController,
                            minLines: 3,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: "Tell us about your background, special skills...",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_forward),
                          iconAlignment: IconAlignment.end,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              sharedData['experience'] = _selectedDuration;
                              sharedData['otherInfo'] = _optionalInfoController.text;
                              Navigator.pushNamed(context, "/selectService");
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
      ),
    );
  }
}
