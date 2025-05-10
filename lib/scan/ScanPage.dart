import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter_application_2/scan/DataTreat.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}
class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List? _hasilPred;
  DataTreat dt = DataTreat();
  DataObat dob = DataObat();

  @override
  void initState() {
    super.initState();
    FutureBuilder(future: loadModel(), builder: (_, snap) => Text(""));
  }

  // Fungsi untuk memilih gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  // Fungsi untuk memuat model TensorFlow Lite
  Future<String?> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model/tomato_model.tflite",
      labels: "assets/model/labels.txt",
      useGpuDelegate: false,
    );
    log("Model loaded: $res");
    return res;
  }

  // Fungsi untuk melakukan prediksi
  Future<dynamic> predict(String path) async {
    var prediksi = await Tflite.runModelOnImage(
        path: path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 3,
        threshold: 0.2,
        asynch: true);
    log("prediksi : ${prediksi}");
    return prediksi;
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Tanaman'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placeholder untuk gambar
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                image: _imageFile != null
                    ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageFile == null
                  ? const Center(
                      child: Text(
                        'No Image Selected',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 32),
            // Tombol Galeri di sebelah kiri dan Kamera di sebelah kanan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo, color: Colors.orange),
                    label: const Text(
                      'Galeri',
                      style: TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    label: const Text(
                      'Kamera',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tombol Deteksi
            ElevatedButton.icon(
              onPressed: () async {
                if (_imageFile != null) {
                  var hasil = await predict(_imageFile!.path);
                  setState(() {
                    _hasilPred = hasil; // Simpan hasil prediksi
                  });
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return _hasilPred != null && _hasilPred!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hasil Prediksi:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Label: ${_hasilPred![0]['label']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Confidence: ${(_hasilPred![0]['confidence'] * 100).toStringAsFixed(2)}%',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Treatment:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dt.treatment[_hasilPred![0]['index']],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Obat:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dob.obat[_hasilPred![0]['index']],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            );
                    },
                  );
                }
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Deteksi',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
