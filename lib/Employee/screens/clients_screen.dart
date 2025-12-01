import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/Employee/widgets/bottom_navbar.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Clients",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // =========================== BODY ===========================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Customer").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No clients found.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final clients = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) =>
            const SizedBox(height: 12),

            itemCount: clients.length,
            itemBuilder: (context, index) {
              final data = clients[index].data() as Map<String, dynamic>;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/emp_client_profile',
                    arguments: {
                      "clientId": clients[index].id,
                      "name": data["Customer_Name"] ?? "",
                      "email": data["Customer_Email"] ?? "",
                      "phone": data["Customer_Mobile_Number"] ?? "",
                      "avatar": data["avatar_url"] ?? "",
                    },
                  );
                },

                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ---------------- PROFILE PHOTO ----------------
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white24,
                        backgroundImage: (data["avatar_url"] != null &&
                            data["avatar_url"].toString().isNotEmpty)
                            ? NetworkImage(data["avatar_url"])
                            : null,
                        child: (data["avatar_url"] == null ||
                            data["avatar_url"].toString().isEmpty)
                            ? const Icon(Icons.person,
                            color: Colors.white, size: 40)
                            : null,
                      ),

                      const SizedBox(width: 18),

                      // ---------------- CLIENT DETAILS ----------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["Customer_Name"] ?? "Unknown",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.white54, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data["Customer_Mobile_Number"] ??
                                        "Not available",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(Icons.email,
                                    color: Colors.white54, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data["Customer_Email"] ??
                                        "Not available",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white38, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // ======================= BOTTOM NAVBAR =======================
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) Navigator.pushNamed(context, '/emp_home');
          if (i == 1) Navigator.pushNamed(context, '/emp_slots');
          if (i == 2) return;
          if (i == 3) Navigator.pushNamed(context, '/employee_profile');
        },
      ),
    );
  }
}
