import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/service.dart';
import '../models/user_profile.dart';
import '../widgets/service_card.dart';
import '../widgets/profile_section.dart';
import '../widgets/dialogs.dart';

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

  final UserProfile _userProfile = UserProfile.sampleProfile;
  final List<Service> _services = Service.sampleServices;

  void _handleServiceTap(Service service) {
    setState(() {
      _showingSubServices = true;
      _selectedService = service.name;
    });
  }

  void _handleBack() {
    setState(() {
      _showingSubServices = false;
      _selectedService = '';
    });
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade900,
            elevation: 0,
          ),
          body: FadeInUp(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 50),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _userProfile.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Member since ${_userProfile.memberSince}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ProfileSection(
                      title: 'Email',
                      value: _userProfile.email,
                      icon: Icons.email),
                  ProfileSection(
                      title: 'Phone',
                      value: _userProfile.phone,
                      icon: Icons.phone),
                  ProfileSection(
                      title: 'Address',
                      value: _userProfile.address,
                      icon: Icons.location_on),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Handle edit profile
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Payment Methods'),
            backgroundColor: Colors.blue,
          ),
          body: const Center(
            child: Text(
              'Manage your payment methods here.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        shadowColor: Colors.black54,
        leading: _showingSubServices
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBack,
              )
            : null,
        title: Text(
          _showingSubServices ? _selectedService : 'Connectify',
          style: const TextStyle(
            fontFamily: 'F1',
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: !_showingSubServices ? _buildDrawer() : null,
      body: _buildMainContent(),
      bottomNavigationBar: !_showingSubServices ? _buildBottomAppBar() : null,
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  _userProfile.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  _userProfile.email,
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
              _navigateToProfile(context);
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
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pop(context),
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
      color: Colors.blue.shade700,
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
                      color: Colors.white.withOpacity(0.2),
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
                    size: isSelected ? 28 : 24, // Larger size for selected icon
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
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
        return Icons.search;
      case 2:
        return Icons.notifications;
      case 3:
        return Icons.person;
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
        return FadeInUp(child: const Center(child: Text('Search Page')));
      case 2:
        return FadeInUp(child: const Center(child: Text('Notifications')));
      case 3:
        return FadeInUp(child: const Center(child: Text('Profile')));
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildSubServicesContent() {
    final selectedServiceData =
        _services.firstWhere((service) => service.name == _selectedService);
    final subServices = selectedServiceData.subServices;

    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a service:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subServices.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: selectedServiceData.img,
                        title: Text(
                          subServices[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Handle sub-service selection
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
                    Text(
                      'Hello, ${_userProfile.name.split(' ')[0]}',
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
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search services',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
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
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: 200 * index),
              duration: const Duration(milliseconds: 500),
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
