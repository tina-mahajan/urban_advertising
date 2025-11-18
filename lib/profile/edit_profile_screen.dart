import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../profile/settings_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String? avatar; // stored image URL

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
  }

  // ----------------------------------------------------------------------
  // PICK IMAGE
  // ----------------------------------------------------------------------
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  // ----------------------------------------------------------------------
  // UPDATE PROFILE USING FIREBASE
  // ----------------------------------------------------------------------
  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String uid = user.uid;

      String? uploadedImageUrl = widget.avatar;

      // -----------------------------
      // 1️⃣ Upload Image to Firebase Storage
      // -----------------------------
      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("profile_images")
            .child("$uid.jpg");

        await ref.putFile(selectedImage!);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      // -----------------------------
      // 2️⃣ Update Firebase Auth Email
      // -----------------------------
      if (emailController.text.trim() != widget.email) {
        await user.updateEmail(emailController.text.trim());
      }

      // -----------------------------
      // 3️⃣ Update Firebase Auth Password
      // -----------------------------
      if (passwordController.text.trim().isNotEmpty) {
        await user.updatePassword(passwordController.text.trim());
      }

      // -----------------------------
      // 4️⃣ Update Firestore Customer Document
      // -----------------------------
      await FirebaseFirestore.instance
          .collection("Customer")
          .doc(uid)
          .update({
        "Customer_Name": nameController.text.trim(),
        "Customer_Email": emailController.text.trim(),
        "Customer_Mobile_Number": phoneController.text.trim(),
        "avatar_url": uploadedImageUrl ?? "",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ----------------------------------------------------------------------
  // UI (UNCHANGED)
  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (widget.avatar != null
                        ? NetworkImage(widget.avatar!) as ImageProvider
                        : null),
                    child: widget.avatar == null && selectedImage == null
                        ? const Icon(Icons.person, color: Colors.black, size: 38)
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
            const Text('Change Picture',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),

            _buildTextField('Username', nameController),
            const SizedBox(height: 16),

            _buildTextField('Email', emailController),
            const SizedBox(height: 16),

            _buildTextField('Phone Number', phoneController),
            const SizedBox(height: 16),

            _buildTextField('Password (optional)', passwordController,
                obscure: true),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading ? null : updateProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Update',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------- TextField Builder -----------------------
  static Widget _buildTextField(
      String label, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 15),
        filled: true,
        fillColor: Colors.white10,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
