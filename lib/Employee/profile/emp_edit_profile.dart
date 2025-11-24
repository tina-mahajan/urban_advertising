import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_advertising/Employee/profile/emp_settings.dart';

import '../../core/theme.dart';

class EmployeeEditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String? avatar;

  const EmployeeEditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    this.avatar,
  });

  @override
  State<EmployeeEditProfileScreen> createState() =>
      _EmployeeEditProfileScreenState();
}

class _EmployeeEditProfileScreenState extends State<EmployeeEditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController designationController;
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    designationController = TextEditingController(text: widget.designation);
  }

  // ---------------------------------------------------------
  // PICK PROFILE IMAGE
  // ---------------------------------------------------------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() => selectedImage = File(img.path));
    }
  }

  // ---------------------------------------------------------
  // UPDATE EMPLOYEE PROFILE
  // ---------------------------------------------------------
  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String uid = user.uid;
      String? uploadedImageUrl = widget.avatar;

      // ⚡ Upload new image to Firebase Storage
      if (selectedImage != null) {
        final ref =
        FirebaseStorage.instance.ref().child("employee_avatars/$uid.jpg");

        await ref.putFile(selectedImage!);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      // ⚡ Update email if changed
      if (emailController.text.trim() != widget.email) {
        await user.updateEmail(emailController.text.trim());
      }

      // ⚡ Update password if changed
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text.trim());
      }

      // ⚡ Update Employee Firestore Document
      await FirebaseFirestore.instance.collection("employee").doc(uid).update({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "designation": designationController.text.trim(),
        "avatar": uploadedImageUrl ?? "",
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")));
    }

    setState(() => isLoading = false);
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmployeeSettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ------------------ PROFILE IMAGE ------------------
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white24,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (widget.avatar != null
                        ? NetworkImage(widget.avatar!) as ImageProvider
                        : null),
                    child: widget.avatar == null && selectedImage == null
                        ? const Icon(Icons.person,
                        size: 48, color: Colors.white)
                        : null,
                  ),

                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.black, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Text("Change Picture",
                style: TextStyle(color: Colors.white)),

            const SizedBox(height: 25),

            _buildField("Full Name", nameController),
            const SizedBox(height: 16),

            _buildField("Email Address", emailController),
            const SizedBox(height: 16),

            _buildField("Phone Number", phoneController),
            const SizedBox(height: 16),

            _buildField("Designation", designationController),
            const SizedBox(height: 16),

            _buildField("Password (optional)", passwordController,
                obscure: true),
            const SizedBox(height: 30),

            // ------------------ UPDATE BUTTON ------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors1.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : updateProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Update",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Text Field ----------
  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
