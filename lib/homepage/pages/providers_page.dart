import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class _SampleProvider {
  final String name;
  final String category;
  final String bio;
  final double rating;
  final int jobsCompleted;
  final String experience;
  final String avatarUrl;

  const _SampleProvider({
    required this.name,
    required this.category,
    required this.bio,
    required this.rating,
    required this.jobsCompleted,
    required this.experience,
    required this.avatarUrl,
  });
}

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  String _selectedCategory = 'All';

  static const List<_SampleProvider> _providers = [
    _SampleProvider(
      name: 'Ahmad Khalil',
      category: 'Home Maintenance',
      bio: 'Expert electrician and plumber with over 8 years of experience in residential and commercial repairs.',
      rating: 4.9,
      jobsCompleted: 234,
      experience: 'Expert',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-male-skin-type-4--v1.png',
    ),
    _SampleProvider(
      name: 'Sara Mahmoud',
      category: 'Cleaning',
      bio: 'Professional cleaner specializing in deep cleaning and move-in/move-out services for homes and offices.',
      rating: 4.8,
      jobsCompleted: 189,
      experience: 'Advanced',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-female-skin-type-3.png',
    ),
    _SampleProvider(
      name: 'Omar Hassan',
      category: 'Technology & IT',
      bio: 'Certified network engineer providing smart home installation, computer repair, and Wi-Fi setup.',
      rating: 4.7,
      jobsCompleted: 156,
      experience: 'Expert',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-male-skin-type-5--v1.png',
    ),
    _SampleProvider(
      name: 'Lina Nasser',
      category: 'Personal & Lifestyle',
      bio: 'Licensed beautician offering salon services at home including hair styling, makeup, and skincare.',
      rating: 4.9,
      jobsCompleted: 312,
      experience: 'Expert',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-female-skin-type-4.png',
    ),
    _SampleProvider(
      name: 'Khaled Yousef',
      category: 'Appliance Repair',
      bio: 'Specialized in repairing refrigerators, washing machines, and ovens with quick turnaround times.',
      rating: 4.6,
      jobsCompleted: 98,
      experience: 'Advanced',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-male-skin-type-3--v1.png',
    ),
    _SampleProvider(
      name: 'Dr. Rania Abed',
      category: 'Educational & Tutoring',
      bio: 'Experienced tutor for Mathematics, Physics, and Chemistry with a Ph.D. in Applied Sciences.',
      rating: 5.0,
      jobsCompleted: 421,
      experience: 'Expert',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-female-skin-type-5.png',
    ),
    _SampleProvider(
      name: 'Nabil Karam',
      category: 'Event Support',
      bio: 'Professional event photographer and videographer with creative catering and decoration services.',
      rating: 4.8,
      jobsCompleted: 145,
      experience: 'Advanced',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-male-skin-type-6--v1.png',
    ),
    _SampleProvider(
      name: 'Farah Zidan',
      category: 'Home Maintenance',
      bio: 'Interior painter and gardener bringing life to your home with vibrant colors and green spaces.',
      rating: 4.5,
      jobsCompleted: 72,
      experience: 'Intermediate',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-female-skin-type-1-2.png',
    ),
    _SampleProvider(
      name: 'Tariq Saleh',
      category: 'Cleaning',
      bio: 'Reliable carpet and window cleaning specialist. Eco-friendly products and same-day service.',
      rating: 4.7,
      jobsCompleted: 203,
      experience: 'Advanced',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-male-skin-type-1-2--v1.png',
    ),
    _SampleProvider(
      name: 'Mona Raad',
      category: 'Personal & Lifestyle',
      bio: 'Certified massage therapist and pet care professional providing at-home wellness services.',
      rating: 4.8,
      jobsCompleted: 167,
      experience: 'Expert',
      avatarUrl: 'https://img.icons8.com/color/96/circled-user-female-skin-type-6.png',
    ),
  ];

  List<String> get _categories {
    final cats = _providers.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<_SampleProvider> get _filteredProviders {
    if (_selectedCategory == 'All') return _providers;
    return _providers.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter
        FadeInUp(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.shade100,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        // Providers list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredProviders.length,
            itemBuilder: (context, index) {
              final provider = _filteredProviders[index];
              return FadeInUp(
                delay: Duration(milliseconds: 80 * index),
                child: GestureDetector(
                  onTap: () => _showProviderDetail(provider),
                  child: _buildProviderCard(provider),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(_SampleProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            child: ClipOval(
              child: Image.network(
                provider.avatarUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  color: Colors.blue.shade300,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    provider.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      provider.rating.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.work_outline,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.jobsCompleted} jobs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Chevron
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showProviderDetail(_SampleProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade50,
                child: ClipOval(
                  child: Image.network(
                    provider.avatarUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      color: Colors.blue.shade300,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                provider.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.category,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statItem(
                      Icons.star, Colors.amber.shade600, provider.rating.toString(), 'Rating'),
                  const SizedBox(width: 28),
                  _statItem(Icons.work_outline, Colors.blue,
                      provider.jobsCompleted.toString(), 'Jobs'),
                  const SizedBox(width: 28),
                  _statItem(Icons.trending_up, Colors.green,
                      provider.experience, 'Level'),
                ],
              ),
              const SizedBox(height: 20),
              // Bio
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Contact button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Contact Provider',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
