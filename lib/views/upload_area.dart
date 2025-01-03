import 'package:flutter/material.dart';
import 'package:flutter_cloudinary_file_upload/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';

class UploadArea extends StatefulWidget {
  const UploadArea({super.key});

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

final TextEditingController _usernameController = TextEditingController();

class _UploadAreaState extends State<UploadArea> {
  @override
  Widget build(BuildContext context) {
    // Cast the argument to XFile instead of FilePickerResult
    final XFile selectedFile =
        ModalRoute.of(context)!.settings.arguments as XFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Area"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
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
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 0, 2),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () {
                        _usernameController.clear();
                        Navigator.pushReplacementNamed(context, "/home");
                      },
                      child: const Text("Change Selected photo?"),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 2, 20, 2),
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await uploadToCloudinary(selectedFile);

                      if (result) {
                        // Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, "/mainPage");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Error: Cannot Upload Your Photo"),
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.navigate_next_sharp,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
