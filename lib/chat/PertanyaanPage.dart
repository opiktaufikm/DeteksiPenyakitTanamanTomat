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

  List<Map<String, dynamic>> _pertanyaanList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPertanyaan();
  }

  Future<void> _loadPertanyaan() async {
    setState(() => _loading = true);
    final response = await supabase
        .from('pertanyaan')
        .select('*')
        .order('created_at', ascending: false);

    setState(() {
      _pertanyaanList = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  void _bukaFormTambahPertanyaan() async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TambahPertanyaan(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );

    if (result == true) {
      _loadPertanyaan(); // Refresh setelah menambah
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

  void _navigateToDetailPage(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailPage(item: item)),
    );

    if (result == true) {
      _loadPertanyaan(); // Refresh setelah delete
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPertanyaan,
              child: _pertanyaanList.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text("Belum ada pertanyaan.")),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _pertanyaanList.length,
                      itemBuilder: (context, index) {
                        final item = _pertanyaanList[index];
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                    ),
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
