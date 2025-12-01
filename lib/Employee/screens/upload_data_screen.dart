import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_advertising/core/theme.dart'; // contains AppColors1

class UploadDataScreen extends StatefulWidget {
  const UploadDataScreen({super.key});

  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {
  List<File> selectedFiles = [];
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // PICK MULTIPLE IMAGES
  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();

    if (picked != null && picked.isNotEmpty) {
      setState(() {
        selectedFiles.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  // PICK VIDEO
  Future<void> pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedFiles.add(File(picked.path));
      });
    }
  }

  // UPLOAD ALL FILES
  Future<void> uploadAll() async {
    if (selectedFiles.isEmpty) return;

    setState(() => isUploading = true);

    List<String> urls = [];

    for (var file in selectedFiles) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child("employee_work/$fileName");

      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      urls.add(url);
    }

    await FirebaseFirestore.instance.collection("employee_uploads").add({
      "files": urls,
      "uploaded_at": DateTime.now(),
    });

    setState(() {
      selectedFiles.clear();
      isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Completed"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors1.darkBackground,

      appBar: AppBar(
        title: const Text("Upload Work"),
        backgroundColor: AppColors1.cardBackground,
        foregroundColor: AppColors1.textLight,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : uploadAll,
        label: Text(isUploading ? "Uploading..." : "Upload"),
        icon: const Icon(Icons.cloud_upload),
        backgroundColor: AppColors1.primaryAccent,
        foregroundColor: AppColors1.textLight,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ---------- PICK BUTTONS ----------
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: pickVideo,
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text("Pick Video"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors1.primaryAccentLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ---------- FILE PREVIEW ----------
            Expanded(
              child: selectedFiles.isEmpty
                  ? const Center(
                child: Text(
                  "No files selected",
                  style: TextStyle(color: AppColors1.secondaryText),
                ),
              )
                  : GridView.builder(
                itemCount: selectedFiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  File file = selectedFiles[index];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors1.cardBackground,
                      border: Border.all(
                        color: AppColors1.primaryAccent.withOpacity(0.3),
                      ),
                    ),
                    child: file.path.endsWith(".mp4")
                        ? const Center(
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
