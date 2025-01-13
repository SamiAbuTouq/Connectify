import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String memberSince;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.memberSince,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      memberSince: data['memberSince'] ?? '',
    );
  }

  static UserProfile sampleProfile = UserProfile(
    id: 'sample',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1 234 567 8900',
    address: '123 Main St, City, Country',
    memberSince: 'January 2024',
  );

  static Future<UserProfile> fetchProfile(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return sampleProfile;
    }
  }
}
