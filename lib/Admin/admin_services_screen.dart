import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminServicesScreen extends StatelessWidget {
  const AdminServicesScreen({super.key});

  // --------------------------------------------------
  // 🔥 ADD SERVICE DIALOG (IMPROVED UI)
  // --------------------------------------------------
  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors1.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _inputField(
                controller: nameController,
                label: "Service Name",
                icon: Icons.design_services_outlined,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: descController,
                label: "Description",
                icon: Icons.description_outlined,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: priceController,
                label: "Price (₹)",
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors1.primaryAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty) {
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection("services")
                          .add({
                        "name": nameController.text.trim(),
                        "description": descController.text.trim(),
                        "price": int.parse(priceController.text),
                        "isActive": true,
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Add Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Services"),
        backgroundColor: AppColors1.cardBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("services").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No services added yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                color: AppColors1.cardBackground,
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    data["name"] ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "₹ ${data["price"]}\n${data["description"] ?? ""}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --------------------------------------------------
// 🔧 INPUT FIELD WIDGET
// --------------------------------------------------
Widget _inputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.black.withOpacity(0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
