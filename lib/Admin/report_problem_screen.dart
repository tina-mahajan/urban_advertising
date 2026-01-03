import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _controller = TextEditingController();
  String _issueType = 'App Issue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Report a Problem',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dropdown(),
            const SizedBox(height: 16),
            _textField(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors1.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButton<String>(
        value: _issueType,
        dropdownColor: AppColors1.cardBackground,
        isExpanded: true,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'App Issue', child: Text('App Issue')),
          DropdownMenuItem(value: 'Payment Issue', child: Text('Payment Issue')),
          DropdownMenuItem(value: 'Booking Issue', child: Text('Booking Issue')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: (v) => setState(() => _issueType = v!),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _textField() {
    return TextField(
      controller: _controller,
      maxLines: 5,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Describe your issue...',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColors1.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Problem reported successfully')),
    );

    Navigator.pop(context);
  }
}
