import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../widgets/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/module/shared_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showingSubServices = false;
  String _selectedService = '';
  final Set<String> _selectedSubServices = {};

  final List<Service> _services = Service.sampleServices;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _handleServiceTap(Service service) {
    setState(() {
      _showingSubServices = true;
      _selectedService = service.name;
      _selectedSubServices.clear();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      print('User ID: $userId');
      if (userId.isEmpty) throw Exception('User not logged in.');
      final userData = await fetchUserData(userId);
      print('Fetched user data: $userData');
      setState(() {
        userProfile = userData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _handleBack() {
    setState(() {
      _showingSubServices = false;
      _selectedService = '';
      _selectedSubServices.clear();
    });
  }

  void _handleSubServiceSelection(String subService) {
    setState(() {
      if (_selectedSubServices.contains(subService)) {
        _selectedSubServices.remove(subService);
      } else {
        _selectedSubServices.add(subService);
      }
    });
  }

  void _navigateToPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Payment Methods',
              style: TextStyle(
                fontFamily: "F1",
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: const PaymentMethodsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.black54,
        leading: _showingSubServices
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBack,
              )
            : null,
        title: const Text(
          'Connectify',
          style: TextStyle(
            fontFamily: 'F1',
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: !_showingSubServices ? _buildDrawer() : null,
      body: _showingSubServices
          ? _buildSubServicesContent()
          : _buildMainContent(),
      bottomNavigationBar: !_showingSubServices ? _buildBottomAppBar() : null,
      floatingActionButton:
          _showingSubServices && _selectedSubServices.isNotEmpty
              ? FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: _showBookingDialog,
                  child: const Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                )
              : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      width: 275,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 33, 149, 243),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(userProfile?['imageUrl'] ?? ''),
                  child: userProfile?['imageUrl']?.isNotEmpty == true
                      ? null
                      : Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  userProfile?['username'] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userProfile?['email'] ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profilePage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.blue),
            title: const Text('Payment Method'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPaymentMethod();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/helpSupportPage");
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      height: 60,
      color: Colors.blue,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final bool isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: isSelected ? 10 : 0),
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(60),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForIndex(index),
                    color: isSelected
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color.fromARGB(255, 0, 0, 0),
                    size: isSelected ? 28 : 24,
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.calendar_month_rounded;
      case 2:
        return Icons.bookmark_outline_rounded;
      case 3:
        return Icons.people;
      default:
        return Icons.error;
    }
  }

  Widget _buildMainContent() {
    if (_showingSubServices) {
      return _buildSubServicesContent();
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return FadeInUp(
            child: const Center(
                child:
                    Text('your bookings will appear here\n Comming Soon...')));
      case 2:
        return FadeInUp(
            child: const Center(
                child:
                    Text('here you can see your bookmarks\n Comming Soon...')));
      case 3:
        return FadeInUp(
            child: const Center(
                child: Text(
                    'here you can see all service providers\n Comming Soon...')));
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildSubServicesContent() {
    final selectedServiceData =
        _services.firstWhere((service) => service.name == _selectedService);
    final subServices = selectedServiceData.subServices;
    final subServicesImg = selectedServiceData.subServicesImg;
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select services:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subServices.length < subServicesImg.length
                    ? subServices.length
                    : subServicesImg.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index >= subServices.length ||
                      index >= subServicesImg.length) {
                    return const SizedBox();
                  }
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: Card(
                      color: _selectedSubServices.contains(subServices[index])
                          ? Colors.blue.shade100
                          : const Color.fromARGB(255, 240, 240, 240),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Image.network(
                          subServicesImg[index],
                          width: 50,
                        ),
                        title: Text(
                          subServices[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: _selectedSubServices
                                .contains(subServices[index])
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          _handleSubServiceSelection(subServices[index]);
                        },
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
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You are about to book the following services:'),
              const SizedBox(height: 10),
              ...(_selectedSubServices.map((service) => Text('• $service'))),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 127, 191, 244)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                await saveBooking(
                  serviceName: _selectedService,
                  subServices: _selectedSubServices.toList(),
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Booking confirmed!',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  _showingSubServices = false;
                  _selectedService = '';
                  _selectedSubServices.clear();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: FadeInUp(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Hello, ${userProfile?['username'] ?? "".split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'What service do you\nneed today?',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // TextField(
                    //   decoration: InputDecoration(
                    //     hintText: 'Search services',
                    //     prefixIcon: const Icon(Icons.search),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: BorderSide.none,
                    //     ),
                    //     filled: true,
                    //     fillColor: Colors.grey.shade100,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => _handleServiceTap(_services[index]),
                child: ServiceCard(service: _services[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PaymentMethodsScreenState();
  }
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<String> _paymentMethods = [
    'Credit Card',
    'PayPal',
    'Google Pay',
    'Apple Pay',
    'Bank Transfer',
  ];

  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Payment Method:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentMethods.length + 1, // +1 for the button
            itemBuilder: (context, index) {
              if (index < _paymentMethods.length) {
                return RadioListTile<String>(
                  title: Text(_paymentMethods[index]),
                  value: _paymentMethods[index],
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _selectedPaymentMethod == null
                          ? null
                          : () {
                              // Logic to save the selected payment method can go here
                              Navigator.pop(
                                  context); // Navigate back to home screen
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
