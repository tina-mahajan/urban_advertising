import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_advertising/core/theme.dart';

class TeamChatScreen extends StatefulWidget {
  const TeamChatScreen({super.key});

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String employeeName = "";
  String employeeId = "";

  @override
  void initState() {
    super.initState();
    loadEmployee();
  }

  Future<void> loadEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString("name") ?? "Employee";
      employeeId = prefs.getString("uid") ?? "";
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection("team_chat") // 🔥 auto-created
        .add({
      "senderId": employeeId,
      "senderName": employeeName,
      "message": messageController.text.trim(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    messageController.clear();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,
      appBar: AppBar(
        title: const Text("Team Chat"),
        backgroundColor: AppColors1.cardBackground,
      ),
      body: Column(
        children: [
          // ---------------- MESSAGES ----------------
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

                    bool isMe = data["senderId"] == employeeId;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints:
                        const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors1.primaryAccent
                              : AppColors1.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: isMe
                              ? null
                              : Border.all(
                            color: AppColors1.primaryAccent
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                data["senderName"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              data["message"] ?? "",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ---------------- INPUT ----------------
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
                  icon: const Icon(Icons.send,
                      color: AppColors1.primaryAccent),
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
