import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letzeat/views/main_app.dart';
import 'package:letzeat/views/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "", password = "";

  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();

  Future<void> userlogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Optional: Fetch user data from Firestore
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // You can extract user data like this if needed:
        // String name = userDoc['name'];
        // Store it in app state if needed
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainApp()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') {
        message = "No User Found for that Email";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password provided";
      } else {
        message = "Error: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(message, style: const TextStyle(fontSize: 18.0)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 200),
          const SizedBox(height: 20),
          const Text(
            'Login to Your Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Please log in to continue',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: mailcontroller,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: passwordcontroller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (mailcontroller.text.isNotEmpty &&
                  passwordcontroller.text.isNotEmpty) {
                setState(() {
                  email = mailcontroller.text;
                  password = passwordcontroller.text;
                });
                userlogin();
              }
            },
            child: const Text('Login'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // Navigate to registration page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: const Text('Don\'t have an account? Register here'),
          ),
        ],
      ),
    );
  }
}
