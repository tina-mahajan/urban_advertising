import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:urban_advertising/services/push_notification_service.dart';
import 'package:urban_advertising/core/theme.dart';

class AdminTeamChatScreen extends StatefulWidget {
  const AdminTeamChatScreen({super.key});

  @override
  State<AdminTeamChatScreen> createState() => _AdminTeamChatScreenState();
}

class _AdminTeamChatScreenState extends State<AdminTeamChatScreen> {

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String adminName = "";
  String adminId = "";

  final DateFormat timeFormatter = DateFormat("hh:mm a");

  @override
  void initState() {
    super.initState();
    loadAdmin();
  }

  Future<void> loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      adminName = prefs.getString("admin_name") ?? "Admin";
      adminId = prefs.getString("uid") ?? "";
    });
  }

  Future<void> sendMessage() async {

    if (messageController.text.trim().isEmpty) return;

    final String msg = messageController.text.trim();

    await FirebaseFirestore.instance
        .collection("team_chat")
        .add({
      "senderId": adminId,
      "senderName": adminName,
      "message": msg,
      "createdAt": FieldValue.serverTimestamp(),
      "role": "admin"
    });

    messageController.clear();

    // NOTIFY ALL EMPLOYEES WHEN ADMIN SEND CHAT
    await notifyEmployeesOnAdminChat(msg);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

// NOTIFY EMPLOYEES WHEN ADMIN SENDS CHAT
  Future<void> notifyEmployeesOnAdminChat(String message) async {

    try {

      final empSnapshot = await FirebaseFirestore.instance
          .collection("employee")
          .get();

      for (var doc in empSnapshot.docs) {

        final token = doc.data()["fcmToken"];

        if (token == null || token.toString().isEmpty) continue;

        await PushNotificationService.sendNotification(
          token: token.toString(),
          title: "New Chat Message",
          body: "$adminName: $message",
        );
      }

    } catch (e) {
      print("❌ Employee Notification Error: $e");
    }
  }


  Widget buildMessageItem(Map<String, dynamic> data) {

    bool isMe = data["senderId"] == adminId;

    Timestamp? ts = data["createdAt"];
    String time = ts != null
        ? timeFormatter.format(ts.toDate())
        : "";

    // JUST USE ACTUAL SENDER NAME – NO STATIC TEXT
    String sender = (data["senderName"] ?? "").toString();

    if (sender.isEmpty) {
      sender = "Unknown Sender";
    }

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors1.primaryAccent
              : AppColors1.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: isMe
              ? null
              : Border.all(color: AppColors1.primaryAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                sender,
                style: TextStyle(
                  color: AppColors1.primaryAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 6),

            Text(
              data["message"] ?? "",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15),
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                time,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11),
              ),
            ),
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
        title: const Text("Admin – Team Chat"),
        backgroundColor: AppColors1.cardBackground,
      ),

      body: Column(
        children: [

          // ============== MESSAGES ==============

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("team_chat")
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    return buildMessageItem(data);
                  },
                );
              },
            ),
          ),

          // ============== INPUT BOX ==============

          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors1.cardBackground,
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      hintStyle:
                      const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors1.darkBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
