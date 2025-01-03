import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _email = '';
  String _username = '';
  String _pass = '';
  FilePickerResult? _filePickerResult;
  File? _selectedImage;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    print(_email);
    print(_pass);

    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    try {
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _pass);
        print(userCredentials);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _pass);
        print(userCredentials);
        Navigator.restorablePushNamedAndRemoveUntil(
            context, "/home", (route) => false);
        // final storageRef = FirebaseStorage.instance
        //     .ref()
        //     .child('user_images')
        //     .child('${userCredentials.user!.uid}.jpg');

        // await storageRef.putFile(_selectedImage!);
        // final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _username,
          'email': _email,
          // 'image_url': imageUrl,
        });
        print("ddddone");
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //? you can whatever you want
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color.fromARGB(255, 255, 69, 69),
        content: Text(error.message ?? "Authentication Failed"),
        duration: const Duration(milliseconds: 2500),
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(221, 110, 110, 110),
                Color.fromARGB(221, 255, 255, 255)
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(172, 0, 0, 0),
                          spreadRadius: 20,
                          blurRadius: 300,
                          offset: Offset(5, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/logo/T-logo.png',
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Card(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    margin: const EdgeInsets.fromLTRB(45, 30, 45, 20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogin)
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              const SizedBox(
                                height: 21,
                              ),
                              if (!_isLogin)
                                TextFormField(
                                  decoration: const InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.person_outline_sharp),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 91, 187, 255)),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      labelText: 'Username'),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length < 4) {
                                      return 'Please enter at least 4 characters.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _username = value!;
                                  },
                                ),
                              if (!_isLogin)
                                const SizedBox(
                                  height: 21,
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 91, 187, 255)),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  labelText: 'Email Address',
                                  // hintText: 'Enter Your Email Address',
                                ),
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  _email = value!;
                                },
                                controller: _emailController,
                              ),
                              const SizedBox(
                                height: 21,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.password_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(255, 91, 187, 255)),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  labelText: 'Password',
                                  // hintText: 'Enter Your Email Address',
                                ),
                                autocorrect: false,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  _pass = value!;
                                },
                                controller: _passwordController,
                              ),
                              const SizedBox(
                                height: 21,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(206, 106, 166, 255),
                                    foregroundColor: const Color.fromARGB(
                                        255, 240, 215, 29)),
                                onPressed: _submit,
                                child: Text(_isLogin ? "Sign In" : "Sign Up"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(172, 0, 0, 0),
                            spreadRadius: 20,
                            blurRadius: 300,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        _isLogin
                            ? 'Create an account'
                            : "I already have an account",
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
