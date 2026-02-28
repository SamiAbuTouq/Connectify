import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final Set<String> _bookmarkedProviderIds = {};

  final List<String> _filterOptions = [
    'All',
    'Home Maintenance',
    'Appliance Repair',
    'Technology & IT',
    'Personal & Lifestyle',
    'Educational & Tutoring',
    'Event Support',
    'Cleaning',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    if (_userId.isEmpty) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('bookmarks')
        .get();
    setState(() {
      _bookmarkedProviderIds.clear();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['providerId'] != null) {
          _bookmarkedProviderIds.add(data['providerId']);
        }
      }
    });
  }

  Future<void> _toggleBookmark(Map<String, dynamic> provider, String providerId) async {
    if (_userId.isEmpty) return;

    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('bookmarks');

    if (_bookmarkedProviderIds.contains(providerId)) {
      // Remove bookmark
      final snap =
          await bookmarksRef.where('providerId', isEqualTo: providerId).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _bookmarkedProviderIds.remove(providerId);
      });
    } else {
      // Add bookmark
      await bookmarksRef.add({
        'providerId': providerId,
        'providerName': provider['username'] ?? 'Unknown',
        'providerImage': provider['imageUrl'] ?? '',
        'mainService': provider['service'] ?? '',
        'experience': provider['experience'] ?? '',
        'subServices': List<String>.from(provider['subServices'] ?? []),
        'savedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _bookmarkedProviderIds.add(providerId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search providers...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        // Filter chips
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final filter = _filterOptions[index];
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey.shade100,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = filter),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Providers list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('provider', isEqualTo: 'true')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Something went wrong',
                        style: TextStyle(
                            color: Colors.red.shade400, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              var docs = snapshot.data?.docs ?? [];

              // Filter out current user
              docs = docs.where((doc) => doc.id != _userId).toList();

              // Apply search
              if (_searchQuery.isNotEmpty) {
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      (data['username'] ?? '').toString().toLowerCase();
                  final service =
                      (data['service'] ?? '').toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return name.contains(query) || service.contains(query);
                }).toList();
              }

              // Apply category filter
              if (_selectedFilter != 'All') {
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final service = (data['service'] ?? '').toString();
                  return service == _selectedFilter;
                }).toList();
              }

              if (docs.isEmpty) {
                return FadeInUp(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No providers found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'All'
                              ? 'Try adjusting your search or filter'
                              : 'Service providers will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final providerId = docs[index].id;
                  final name = data['username'] ?? 'Unknown';
                  final imageUrl = data['imageUrl'] ?? '';
                  final mainService = data['service'] ?? '';
                  final experience = data['experience'] ?? '';
                  final subServices =
                      List<String>.from(data['subServices'] ?? []);
                  final isBookmarked =
                      _bookmarkedProviderIds.contains(providerId);

                  return FadeInUp(
                    delay: Duration(milliseconds: 60 * index),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showProviderDetail(
                            context, data, providerId, isBookmarked),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blue.shade50,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? Icon(Icons.person,
                                        color: Colors.blue.shade300, size: 28)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (mainService.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.work_outline,
                                              size: 14,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              mainService,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (experience.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.star_outline,
                                              size: 14,
                                              color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            experience,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (subServices.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children:
                                            subServices.take(3).map((s) {
                                          return Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: isBookmarked
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                ),
                                onPressed: () =>
                                    _toggleBookmark(data, providerId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProviderDetail(BuildContext context, Map<String, dynamic> data,
      String providerId, bool isBookmarked) {
    final name = data['username'] ?? 'Unknown';
    final imageUrl = data['imageUrl'] ?? '';
    final mainService = data['service'] ?? '';
    final experience = data['experience'] ?? '';
    final email = data['email'] ?? '';
    final otherInfo = data['otherInfo'] ?? '';
    final subServices = List<String>.from(data['subServices'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.blue.shade50,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? Icon(Icons.person,
                                      color: Colors.blue.shade300, size: 45)
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (mainService.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                mainService,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (email.isNotEmpty)
                        _detailRow(Icons.email_outlined, 'Email', email),
                      if (experience.isNotEmpty)
                        _detailRow(Icons.work_outline, 'Experience', experience),
                      if (otherInfo.isNotEmpty)
                        _detailRow(Icons.info_outline, 'Additional Info', otherInfo),
                      if (subServices.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Services Offered',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: subServices.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.blue.shade100),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            isBookmarked
                                ? 'Remove Bookmark'
                                : 'Save Provider',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _toggleBookmark(data, providerId);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
