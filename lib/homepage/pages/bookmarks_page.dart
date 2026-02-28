import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';

class BookmarksPage extends StatefulWidget {
  final Function(Service) onServiceTap;

  const BookmarksPage({super.key, required this.onServiceTap});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final bookmarkedNames =
            List<String>.from(userData['bookmarkedServices'] ?? []);

        if (bookmarkedNames.isEmpty) {
          return FadeInUp(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on services to save them here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Match bookmarked names to actual Service objects
        final allServices = Service.sampleServices;
        final bookmarkedServices = allServices
            .where((s) => bookmarkedNames.contains(s.name))
            .toList();

        if (bookmarkedServices.isEmpty) {
          return FadeInUp(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return FadeInUp(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your saved services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bookmarkedServices.length} service${bookmarkedServices.length > 1 ? 's' : ''} bookmarked',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: bookmarkedServices.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 80 * index),
                        child: GestureDetector(
                          onTap: () =>
                              widget.onServiceTap(bookmarkedServices[index]),
                          child: ServiceCard(
                            service: bookmarkedServices[index],
                            isBookmarked: true,
                            onBookmarkToggle: () => _toggleBookmark(
                              bookmarkedServices[index].name,
                              bookmarkedNames,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleBookmark(
      String serviceName, List<String> currentBookmarks) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    if (currentBookmarks.contains(serviceName)) {
      await userRef.update({
        'bookmarkedServices': FieldValue.arrayRemove([serviceName]),
      });
    } else {
      await userRef.update({
        'bookmarkedServices': FieldValue.arrayUnion([serviceName]),
      });
    }
  }
}
