import '/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

var _buttonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  iconColor: Colors.white,
  iconSize: 24,
  foregroundColor: Colors.white,
  backgroundColor: Colors.black,
  // side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
  // elevation: 20,
  // shadowColor: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 40),
);

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Google sign-in was canceled.')),
        // );
        return Future.error('Sign-in canceled by user.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return Future.error('Google authentication failed.');
      }
      print("1");

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("2");

      // Sign in with Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print("3");
      // Save user info to Firestore
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': user.displayName ?? 'Anonymous',
          'email': user.email,
          'image_url': user.photoURL,
        }, SetOptions(merge: true));
      }
      Navigator.pushReplacementNamed(context, "/homePage");

      return userCredential;
    } catch (error) {
      print('Google sign-in error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $error')),
      );
      return Future.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Logo(),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Get started with your account",
                        style: TextStyle(fontFamily: "F2", fontSize: 15),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * .9,
                          child: TextFormField(
                            validator: (value) => value!.isEmpty
                                ? "Email cannot be empty."
                                : null,
                            controller: _emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                              label: Text("Email"),
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          // validator: (value) => value!.length < 8
                          //     ? "Password should have atleast 8 characters."
                          //     : null,
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_outlined),
                            border: OutlineInputBorder(),
                            label: Text("Password"),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Center(
                        child: SizedBox(
                          height: 55,
                          width: MediaQuery.of(context).size.width * .88,
                          //MediaQuery.of(context).size --> gives the dimensions of the screen
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            iconAlignment: IconAlignment.end,
                            style: _buttonStyle,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                AuthService()
                                    .loginWithEmail(_emailController.text,
                                        _passwordController.text)
                                    .then(
                                  (value) {
                                    if (value == "Login Successful") {
                                      Navigator
                                          .restorablePushNamedAndRemoveUntil(
                                              context,
                                              "/homePage",
                                              (route) => false);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          value,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                      ));
                                    }
                                  },
                                );
                              }
                            },
                            label: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Center(
                        child: SizedBox(
                          height: 55,
                          width: MediaQuery.of(context).size.width * .88,
                          child: ElevatedButton(
                            iconAlignment: IconAlignment.end,
                            style: _buttonStyle,
                            onPressed: signInWithGoogle,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/logo/google.png",
                                  width: 27,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  "Sign in with Google",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(40, 71, 65, 65),
                                  spreadRadius: 1,
                                  blurRadius: 35,
                                  offset: Offset(5, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, "/signup");
                                  },
                                  child: const Text("Sign Up"),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
