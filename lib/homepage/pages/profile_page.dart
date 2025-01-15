import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/profile_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/module/shared_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not logged in.');
      final userData = await fetchUserData(userId);
      setState(() {
        userProfile = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              fontFamily: "F1",
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : FadeInUp(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue,
                                backgroundImage: NetworkImage(
                                    userProfile?['imageUrl'] ?? ''),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                userProfile?['username'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userProfile?['provider'] == "true"
                                    ? 'I am a service provider'
                                    : 'I am a service requester',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ProfileSection(
                          title: 'Email',
                          value: userProfile?['email'] ?? 'N/A',
                          icon: Icons.email,
                        ),
                        ProfileSection(
                          title: 'Experience',
                          value: userProfile?['experience'] ?? 'N/A',
                          icon: Icons.work,
                        ),
                        ProfileSection(
                          title: 'Other Info',
                          value: userProfile?['otherInfo'] ?? 'N/A',
                          icon: Icons.info,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Sub Services:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...(userProfile?['subServices'] as List<dynamic>? ?? [])
                            .map<Widget>((service) => ListTile(
                                  leading: const Icon(Icons.check_circle,
                                      color: Colors.blue),
                                  title: Text(service),
                                )),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Return Home',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
