import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FreeUpSpaceScreen extends StatefulWidget {
  const FreeUpSpaceScreen({super.key});

  @override
  State<FreeUpSpaceScreen> createState() => _FreeUpSpaceScreenState();
}

class _FreeUpSpaceScreenState extends State<FreeUpSpaceScreen> {
  double _cacheSizeMB = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSize();
  }

  Future<void> _loadSize() async {
    final dir = await getTemporaryDirectory();
    double size = await _dirSize(dir);

    if (!mounted) return;

    setState(() {
      _cacheSizeMB = size / (1024 * 1024);
      _loading = false;
    });
  }

  Future<double> _dirSize(Directory dir) async {
    double size = 0;
    if (dir.existsSync()) {
      for (final file in dir.listSync(recursive: true)) {
        if (file is File) {
          size += file.lengthSync();
        }
      }
    }
    return size;
  }

  Future<void> _clearTemp() async {
    final dir = await getTemporaryDirectory();
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }

    await _loadSize();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Temporary files cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Free Up Space")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Temporary Storage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _loading
                ? const CircularProgressIndicator()
                : Text(
              "${_cacheSizeMB.toStringAsFixed(2)} MB used",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cacheSizeMB == 0 ? null : _clearTemp,
                child: const Text("Free Up Space"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
