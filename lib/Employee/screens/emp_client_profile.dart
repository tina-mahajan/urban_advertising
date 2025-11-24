import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

class EmpClientProfileScreen extends StatefulWidget {
  final String clientId;      // only id comes from previous screen
  final String? initialName;  // optional – used only for fast first paint
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAvatar;

  const EmpClientProfileScreen({
    super.key,
    required this.clientId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialAvatar,
  });

  @override
  State<EmpClientProfileScreen> createState() => _EmpClientProfileScreenState();
}

class _EmpClientProfileScreenState extends State<EmpClientProfileScreen> {
  String name = "";
  String email = "";
  String phone = "";
  String business = "";
  String joinedDate = "-";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // show something instantly if we already know it
    name = widget.initialName ?? "";
    email = widget.initialEmail ?? "";
    phone = widget.initialPhone ?? "";

    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Customer")
          .doc(widget.clientId)
          .get();

      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      final Timestamp? createdAt =
      data["created_at"] is Timestamp ? data["created_at"] as Timestamp : null;

      setState(() {
        name = (data["Customer_Name"] ?? "").toString();
        email = (data["Customer_Email"] ?? "").toString();
        phone = (data["Customer_Mobile_Number"] ?? "").toString();
        business = (data["business_name"] ?? "").toString();

        if (createdAt != null) {
          joinedDate = DateFormat("d MMM yyyy").format(createdAt.toDate());
        } else {
          joinedDate = "-";
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading client: $e");
      setState(() => isLoading = false);
    }
  }

  // ---------- UI PARTS ----------

  Widget _miniInfoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors1.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors1.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors1.secondaryAccent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text.isNotEmpty ? text : "-",
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors1.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors1.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors1.primaryAccent.withOpacity(0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : "Unnamed Client",
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (business.isNotEmpty)
                      Text(
                        business,
                        style: const TextStyle(
                          color: AppColors1.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: AppColors1.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          "Joined: $joinedDate",
                          style: const TextStyle(
                            color: AppColors1.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniInfoChip(Icons.mail_outline, email),
              const SizedBox(width: 8),
              _miniInfoChip(Icons.phone_outlined, phone),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bookingHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("slot_request")
          .where("customer_id", isEqualTo: widget.clientId)
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors1.primaryAccent),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              "No bookings yet.",
              style: TextStyle(color: AppColors1.secondaryText, fontSize: 13),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status =
            (data["status"] ?? "pending").toString().toLowerCase();

            Color statusColor;
            Color badgeBg;
            if (status == "approved") {
              statusColor = Colors.greenAccent;
              badgeBg = Colors.green.withOpacity(0.15);
            } else if (status == "rejected") {
              statusColor = Colors.redAccent;
              badgeBg = Colors.red.withOpacity(0.15);
            } else {
              statusColor = Colors.yellowAccent;
              badgeBg = Colors.yellow.withOpacity(0.1);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors1.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors1.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (data["service"] ?? "Unknown Service").toString(),
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Date: ${data["date"] ?? "-"}",
                    style: const TextStyle(
                      color: AppColors1.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Time: ${data["time"] ?? "-"}",
                    style: const TextStyle(
                      color: AppColors1.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  if ((data["message"] ?? "").toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Note: ${data["message"]}",
                      style: const TextStyle(
                        color: AppColors1.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors1.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Client Profile",
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
            color: AppColors1.primaryAccent),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            _sectionTitle("Booking History"),
            _bookingHistory(),
          ],
        ),
      ),
    );
  }
}
