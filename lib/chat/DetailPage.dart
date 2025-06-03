import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pertanyaan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Judul & Detail Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Judul: ${item['judul'] ?? '-'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(item['detail'] ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gambar Box
            Container(
              width: double.infinity,
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: item['gambar_url'] != null &&
                      item['gambar_url'].toString().isNotEmpty
                  ? Image.network(item['gambar_url'], fit: BoxFit.contain)
                  : const Text("Tidak ada gambar"),
            ),
            const SizedBox(height: 16),

            // Jawaban Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['jawaban'] ?? "Belum ada jawaban dari penyuluh.",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
