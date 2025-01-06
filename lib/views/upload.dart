import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cloudinary_file_upload/services/auth_service.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:flutter_cloudinary_file_upload/widgets/user_image_picker.dart';
import 'package:flutter_cloudinary_file_upload/services/cloudinary_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

File? _selectedImage;
final _formKey = GlobalKey<FormState>();
// final ImagePicker _picker = ImagePicker();
final TextEditingController _usernameController = TextEditingController();

var _buttonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  iconColor: Colors.white,
  iconSize: 24,
  foregroundColor: Colors.white,
  backgroundColor: Colors.black,
  side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
  elevation: 20,
  shadowColor: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 40),
);

class _HomePageState extends State<HomePage> {
  // Function to open the file picker for images or videos
  // void _openFilePicker() async {
  //   // Show the dialog to choose between camera and gallery
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (ctx) => Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Take a photo'),
  //             onTap: () async {
  //               Navigator.pop(context); // Close the dialog
  //               XFile? image =
  //                   await _picker.pickImage(source: ImageSource.camera);
  //               if (image != null) {
  //                 Navigator.pushNamed(context, "/upload",
  //                     arguments: image); // Pass XFile
  //               }
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.image),
  //             title: const Text('Choose from gallery'),
  //             onTap: () async {
  //               Navigator.pop(context); // Close the dialog
  //               XFile? image = await _picker.pickImage(
  //                 source: ImageSource.gallery,
  //                 imageQuality: 100, // Maximum quality
  //               );
  //               if (image != null) {
  //                 Navigator.pushReplacementNamed(context, "/upload",
  //                     arguments: image); // Pass XFile
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // final File selectedFile =
    //     ModalRoute.of(context)!.settings.arguments as File;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo/small-logo.png',
          width: 250,
        ),
        //  Text("Connectify")
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              UserImagePicker(
                onPickImage: (pickedImage) {
                  _selectedImage = pickedImage;
                },
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    focusColor: Colors.black,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required.';
                    } else if (value.trim().length <= 2) {
                      return 'Username must be more than 2 characters.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 55,
                width: MediaQuery.of(context).size.width * .88,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  style: _buttonStyle,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final result = await uploadToCloudinary1(_selectedImage);

                      if (result) {
                        Navigator.pushNamed(context, "/imLookingFor");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Error: Cannot Upload Your Photo"),
                          ),
                        );
                      }
                    }
                  },
                  label: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _openFilePicker,
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
