import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectify/widgets/user_image_picker.dart';
import 'package:connectify/services/cloudinary_service.dart';
import '../module/shared_data.dart';

class UploadPhoto extends StatefulWidget {
  const UploadPhoto({super.key});

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
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
  backgroundColor: Colors.blue,
);

class _UploadPhotoState extends State<UploadPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Connectify',
          style: TextStyle(
            fontFamily: "F1",
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 120,
            ),
            UserImagePicker(
              onPickImage: (pickedImage) {
                _selectedImage = pickedImage;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        focusColor: Colors.black,
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        labelStyle:
                            TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                          final result =
                              await uploadToCloudinary1(_selectedImage);

                          if (result) {
                            sharedData['username'] = _usernameController.text;

                            Navigator.pushNamed(context, "/imLookingFor");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("You must upload a profile photo"),
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
          ],
        ),
      ),
    );
  }
}
