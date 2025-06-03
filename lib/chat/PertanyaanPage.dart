import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'DetailPage.dart';
import 'TambahPertanyaan.dart';

class PertanyaanPage extends StatefulWidget {
  const PertanyaanPage({super.key});

  @override
  State<PertanyaanPage> createState() => _PertanyaanPageState();
}

class _PertanyaanPageState extends State<PertanyaanPage> {
  final supabase = Supabase.instance.client;
  File? _selectedImage;

  void _bukaFormTambahPertanyaan() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TambahPertanyaan(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // dari bawah
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );

    // Jika berhasil menambahkan pertanyaan, refresh
    if (result == true) {
      setState(() {}); // panggil fetchQuestions lagi
    }
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

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final response = await supabase
        .from('pertanyaan')
        .select('*')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void _navigateToDetailPage(Map<String, dynamic> item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailPage(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // dari kanan
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada pertanyaan."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  onTap: () => _navigateToDetailPage(item),
                  leading: (item['gambar_url'] != null &&
                          item['gambar_url'].toString().isNotEmpty)
                      ? Image.network(item['gambar_url'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['judul'] ?? 'Tanpa Judul',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['detail'] ?? '',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
        child: FloatingActionButton(
          onPressed: _bukaFormTambahPertanyaan,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
