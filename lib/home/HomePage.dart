import 'package:flutter/material.dart';
import 'package:flutter_application_2/account/AccountPage.dart';
import 'package:flutter_application_2/scan/ScanPage.dart'; 
import 'package:flutter_application_2/viewData/dataClient.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeContent(), // Konten Home
    DataClient(), // Konten Data Client
    AccountPage(), // Konten Account
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Penyakit Tanaman'),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, 
      ),
      body: _pages[_currentIndex], // Menampilkan konten sesuai tab yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah indeks tab yang aktif
          });
        },
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo400.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tomato Disease adalah aplikasi untuk mendeteksi penyakit tanaman tomat. Aplikasi ini membantu Anda menemukan solusi terbaik untuk tanaman Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sembuhkan tanaman anda',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/icon_scan.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Ambil\ngambar', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 24),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon_result.png',
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(height: 8),
                              const Text('Lihat\ndiagnosis', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 24),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon_pes.png',
                                height: 50,
                                width: 50,
                              ),
                              const SizedBox(height: 8),
                              const Text('Dapatkan\nobat', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ScanPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const beginOffset = Offset(1.0, 0.0);
                              const endOffset = Offset.zero;
                              const curve = Curves.easeInOut;

                              var offsetTween = Tween(begin: beginOffset, end: endOffset).chain(CurveTween(curve: curve));
                              var fadeTween = Tween(begin: 0.0, end: 1.0);

                              var offsetAnimation = animation.drive(offsetTween);
                              var fadeAnimation = animation.drive(fadeTween);

                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 260),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Coba sekarang',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
