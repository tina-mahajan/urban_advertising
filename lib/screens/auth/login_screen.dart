import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:urban_advertising/screens/auth/register_screen.dart';
import 'package:urban_advertising/home/home_screen.dart';
import 'package:urban_advertising/Employee/screens/emp_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // -------------------------------------------------------
  // 🔥 FIREBASE LOGIN FUNCTION
  // -------------------------------------------------------
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Please enter email & password", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Login User
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // 2️⃣ Fetch User Details From Firestore
      DocumentSnapshot userDoc;

// First check Customer
      userDoc = await FirebaseFirestore.instance
          .collection("Customer")
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        // If not found, check employee
        userDoc = await FirebaseFirestore.instance
            .collection("employee")
            .doc(uid)
            .get();
      }

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        showMessage("User record not found!", Colors.red);
        return;
      }


      Map<String, dynamic> userData =
      userDoc.data() as Map<String, dynamic>;

      // 3️⃣ Save Data Locally (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("uid", uid);
      await prefs.setString("email", email);
      await prefs.setString("userData", userDoc.data().toString());

      // 4️⃣ Redirect Based on Role (default role = customer)
      String role = userData["role"] ?? "customer";

      if (role == "customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (role == "employee") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
        );
      } else if (role == "admin") {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      }

      setState(() => isLoading = false);

    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);

      String msg = "Login failed";

      if (e.code == "user-not-found") msg = "User not found";
      if (e.code == "wrong-password") msg = "Incorrect password";
      if (e.code == "invalid-email") msg = "Invalid email format";

      showMessage(msg, Colors.red);

    } catch (e) {
      setState(() => isLoading = false);
      showMessage("Error: $e", Colors.red);
    }
  }

  void showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/white.png', height: 60),
                        const SizedBox(height: 20),

                        const Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputStyle(
                              "Email Address", Icons.email),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                          _inputStyle("Password", Icons.lock),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : loginUser,
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                                : const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.white70),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
