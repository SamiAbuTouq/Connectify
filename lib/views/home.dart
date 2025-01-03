import 'package:flutter/material.dart';
import 'package:flutter_cloudinary_file_upload/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  // Function to open the file picker for images or videos
  void _openFilePicker() async {
    // Show the dialog to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context); // Close the dialog
                XFile? image =
                    await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  Navigator.pushReplacementNamed(context, "/upload",
                      arguments: image); // Pass XFile
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context); // Close the dialog
                XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  Navigator.pushReplacementNamed(context, "/upload",
                      arguments: image); // Pass XFile
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Files"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, "/login");
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Tap the button below to select a file',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFilePicker,
        child: const Icon(Icons.add),
      ),
    );
  }
}
