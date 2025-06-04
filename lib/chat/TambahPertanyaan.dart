import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TambahPertanyaan extends StatefulWidget {
  const TambahPertanyaan({super.key});

  @override
  State<TambahPertanyaan> createState() => _TambahPertanyaanState();
}

class _TambahPertanyaanState extends State<TambahPertanyaan> {
  final supabase = Supabase.instance.client;
  final judulController = TextEditingController();
  final detailController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _simpanPertanyaan() async {
    final judul = judulController.text.trim();
    final detail = detailController.text.trim();

    if (judul.isEmpty || detail.isEmpty) return;

    String imageUrl = '';
    if (_selectedImage != null) {
      final uuid = const Uuid().v4();
      final path = '$uuid.jpg';
      await supabase.storage
          .from('pertanyaanimages')
          .upload(path, _selectedImage!);

      imageUrl = supabase.storage.from('pertanyaanimages').getPublicUrl(path);
    }

    await supabase.from('pertanyaan').insert({
      'judul': judul,
      'detail': detail,
      'gambar_url': imageUrl,
    }).then((value) {
      print("INSERT BERHASIL: $value");
    }).catchError((error) {
      print("INSERT ERROR: $error");
    });

    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pertanyaan berhasil disimpan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green, // ✅ AppBar hijau
        title: const Text("Tambah Pertanyaan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  labelText: "Judul Pertanyaan",
                  hintText: "Masukkan judul yang singkat dan jelas",
                  prefixIcon: const Icon(Icons.title),
                  labelStyle: const TextStyle(color: Colors.green),
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: detailController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Detail Pertanyaan",
                  hintText: "Jelaskan pertanyaan Anda secara lengkap...",
                  prefixIcon: const Icon(Icons.description),
                  labelStyle: const TextStyle(color: Colors.green),
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : const Text("Belum ada gambar"),
              const SizedBox(height: 20),

              // ✅ Tombol sejajar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Gambar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _simpanPertanyaan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
