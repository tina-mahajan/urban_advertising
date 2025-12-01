import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminAddOrderScreen extends StatefulWidget {
  const AdminAddOrderScreen({super.key});

  @override
  State<AdminAddOrderScreen> createState() => _AdminAddOrderScreenState();
}

class _AdminAddOrderScreenState extends State<AdminAddOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController =
  TextEditingController();
  final TextEditingController _customerPhoneController =
  TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSaving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTime(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final period = tod.period == DayPeriod.am ? "AM" : "PM";
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection("slot_request").add({
        "customer_name": _customerNameController.text.trim(),
        "customer_phone": _customerPhoneController.text.trim(),
        "service": _serviceController.text.trim(),
        "location": _placeController.text.trim(),
        "message": _messageController.text.trim(),
        "date": _formatDate(_selectedDate!),
        "time": _formatTime(_selectedTime!),
        "status": "pending", // admin created offline order, pending by default
        "source": "offline",
        "created_at": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Offline order added"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.cardBackground,
        elevation: 0,
        title: const Text(
          "Add Offline Order",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _customerNameController,
                label: "Customer Name",
                validator: (v) =>
                v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _customerPhoneController,
                label: "Customer Phone",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _serviceController,
                label: "Service",
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _placeController,
                label: "Place / Location",
              ),
              const SizedBox(height: 12),

              // DATE & TIME ROW
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.white70),
                      label: Text(
                        _selectedDate == null
                            ? "Select Date"
                            : _formatDate(_selectedDate!),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time, color: Colors.white70),
                      label: Text(
                        _selectedTime == null
                            ? "Select Time"
                            : _formatTime(_selectedTime!),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _messageController,
                label: "Notes / Message (optional)",
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_isSaving ? "Saving..." : "Save Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors1.cardBackground,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
