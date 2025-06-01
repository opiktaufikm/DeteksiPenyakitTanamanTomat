import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PertanyaanPage extends StatefulWidget {
  const PertanyaanPage({super.key});

  @override
  State<PertanyaanPage> createState() => _PertanyaanPageState();
}

class _PertanyaanPageState extends State<PertanyaanPage> {
  final supabase = Supabase.instance.client;
  File? _selectedImage;

  void _showAddQuestionForm() {
    final judulController = TextEditingController();
    final detailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Pertanyaan"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: detailController,
                decoration: const InputDecoration(labelText: "Detail"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : const Text("Belum ada gambar"),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
                onPressed: _pickImage,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final judul = judulController.text.trim();
              final detail = detailController.text.trim();

              if (judul.isEmpty || detail.isEmpty) return;

              String imageUrl = '';
              if (_selectedImage != null) {
                final uuid = const Uuid().v4();
                final path = 'pertanyaan/$uuid.jpg';
                await supabase.storage
                    .from('pertanyaan_images')
                    .upload(path, _selectedImage!);
                final urlResponse = supabase.storage
                    .from('pertanyaan_images')
                    .getPublicUrl(path);
                imageUrl = urlResponse;
              }

              await supabase.from('pertanyaan').insert({
                'judul': judul,
                'detail': detail,
                'gambar_url': imageUrl,
              });

              setState(() {
                _selectedImage = null;
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Pertanyaan berhasil disimpan.")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('pertanyaan')
            .select('*')
            .order('created_at', ascending: false)
            .then((value) => value as List<Map<String, dynamic>>),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading:
                      item['gambar_url'] != null && item['gambar_url'] != ''
                          ? Image.network(item['gambar_url'],
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image),
                  title: Text(item['judul'] ?? 'Tanpa Judul',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['detail'] ?? ''),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
        child: FloatingActionButton(
          onPressed: _showAddQuestionForm,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
