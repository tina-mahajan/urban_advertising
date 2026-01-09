import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urban_advertising/core/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    final oldPass = _oldPasswordCtrl.text.trim();
    final newPass = _newPasswordCtrl.text.trim();
    final confirmPass = _confirmPasswordCtrl.text.trim();

    // 🔴 BASIC VALIDATIONS
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showMsg("All fields are required");
      return;
    }

    if (newPass.length < 6) {
      _showMsg("New password must be at least 6 characters");
      return;
    }

    if (newPass != confirmPass) {
      _showMsg("New password and confirm password do not match");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      _showMsg("User not logged in");
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔐 REAUTHENTICATION REQUIRED BY FIREBASE
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      _showMsg("Password updated successfully", success: true);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Failed to change password";
      if (e.code == 'wrong-password') msg = "Old password is incorrect";
      _showMsg(msg);
    } catch (e) {
      _showMsg(e.toString());
    }

    setState(() => _loading = false);
  }

  void _showMsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _passwordField(
              label: "Old Password",
              controller: _oldPasswordCtrl,
              obscure: _obscureOld,
              toggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 16),

            _passwordField(
              label: "New Password",
              controller: _newPasswordCtrl,
              obscure: _obscureNew,
              toggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),

            _passwordField(
              label: "Confirm Password",
              controller: _confirmPasswordCtrl,
              obscure: _obscureConfirm,
              toggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors1.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Update Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
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
