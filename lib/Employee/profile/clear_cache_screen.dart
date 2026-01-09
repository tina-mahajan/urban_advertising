import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ClearCacheScreen extends StatefulWidget {
  const ClearCacheScreen({super.key});

  @override
  State<ClearCacheScreen> createState() => _ClearCacheScreenState();
}

class _ClearCacheScreenState extends State<ClearCacheScreen> {
  bool _clearing = false;

  Future<void> _clearCache() async {
    setState(() => _clearing = true);

    await DefaultCacheManager().emptyCache();

    if (!mounted) return;

    setState(() => _clearing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cache cleared successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clear Cache")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "This will remove cached images and temporary data.",
              style: TextStyle(fontSize: 15),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearing ? null : _clearCache,
                child: _clearing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Clear Cache"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
