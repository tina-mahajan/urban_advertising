import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminEditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;

  const AdminEditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  State<AdminEditProfileScreen> createState() =>
      _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      _showMsg("Name cannot be empty");
      return;
    }

    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('admin')
        .doc(uid)
        .update({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
    });

    setState(() => isSaving = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _inputField("Name", nameController),
            const SizedBox(height: 16),
            _inputField("Phone", phoneController,
                keyboard: TextInputType.phone),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                  color: Colors.black,
                )
                    : const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputField(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
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
      ),
    );
  }
}
