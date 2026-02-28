import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final Map<String, dynamic> sharedData = {};
final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

Future<void> storeUserInfo() async {
  try {
    await Firebase.initializeApp();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference userDoc = firestore.collection('users').doc(userId);

    await userDoc.set(sharedData);
    print("User data stored successfully!");
  } catch (e) {
    print("Error storing user data: $e");
  }
}

// Fetches user data from Firestore
Future<Map<String, dynamic>> fetchUserData(String userId) async {
  try {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    } else {
      return {}; // Return empty map if no data is found
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return {};
  }
}

// Saves a booking to the bookings collection in Firestore
Future<void> saveBooking({
  required String serviceName,
  required List<String> subServices,
}) async {
  try {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': currentUserId,
      'serviceName': serviceName,
      'subServices': subServices,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print("Error saving booking: $e");
  }
}

// Fetches services data from Firestore
Future<List<Map<String, dynamic>>> fetchServicesData() async {
  try {
    QuerySnapshot servicesSnapshot =
        await FirebaseFirestore.instance.collection('services').get();
    return servicesSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    print("Error fetching services data: $e");
    return [];
  }
}
