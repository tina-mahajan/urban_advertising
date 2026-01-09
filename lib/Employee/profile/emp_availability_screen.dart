import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class EmployeeAvailabilityScreen extends StatefulWidget {
  final String employeeUid;

  const EmployeeAvailabilityScreen({
    super.key,
    required this.employeeUid,
  });

  @override
  State<EmployeeAvailabilityScreen> createState() =>
      _EmployeeAvailabilityScreenState();
}

class _EmployeeAvailabilityScreenState
    extends State<EmployeeAvailabilityScreen> {
  String _currentStatus = "available";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection("employee_status")
        .doc(widget.employeeUid)
        .get();

    if (doc.exists) {
      setState(() {
        _currentStatus = doc["status"] ?? "available";
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _currentStatus = status);

    await FirebaseFirestore.instance
        .collection("employee_status")
        .doc(widget.employeeUid)
        .set({
      "employee_id": widget.employeeUid,
      "status": status,
      "updated_at": Timestamp.now(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Status updated to ${_label(status)}"),
      ),
    );
  }

  String _label(String status) {
    switch (status) {
      case "available":
        return "Available";
      case "busy":
        return "Busy";
      case "on_leave":
        return "On Leave";
      default:
        return status;
    }
  }

  Color _color(String status) {
    switch (status) {
      case "available":
        return Colors.greenAccent;
      case "busy":
        return Colors.orangeAccent;
      case "on_leave":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _statusTile(String status, IconData icon) {
    final bool selected = _currentStatus == status;

    return InkWell(
      onTap: () => _updateStatus(status),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors1.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _color(status) : AppColors1.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: _color(status), size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _label(status),
                style: const TextStyle(
                  color: AppColors1.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: _color(status)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Availability Status"),
        backgroundColor: AppColors1.darkBackground,
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors1.primaryAccent,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statusTile(
              "available",
              Icons.check_circle_outline,
            ),
            _statusTile(
              "busy",
              Icons.access_time,
            ),
            _statusTile(
              "on_leave",
              Icons.event_busy,
            ),
          ],
        ),
      ),
    );
  }
}
