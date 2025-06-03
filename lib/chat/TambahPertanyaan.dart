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
      final path = '$uuid.jpg'; // tanpa folder "pertanyaan/"
      await supabase.storage
          .from('pertanyaanimages') // sesuai nama bucket
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
      Navigator.pop(context, true); // kirim sinyal ke halaman sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pertanyaan berhasil disimpan.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pertanyaan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanPertanyaan,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
                child: const Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
