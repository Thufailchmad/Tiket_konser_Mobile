import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo-tiket2.png', 
              height: 80,
            ),
            IconButton(
              icon: Icon(Icons.person),
              color: Color(0xFF0027B4), 
              onPressed: () {
                
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16), 
        child: Column(
          children: [
            Image.asset(
              'assets/sponsor.png'
              , height: 150, 
            ),
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 20),
            //   child: Text(
            //     'TICKETING PARTNER?',
            //     style: TextStyle(
            //         fontSize: 24,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.blue[700]),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Text(
            //     'Kami menyediakan segalanya untuk keberlangsungan event kamu!',
            //     style: TextStyle(fontSize: 16, color: Colors.black54),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            // const SizedBox(height: 20),
            // Kolom pencarian
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Cari Event...',
                ),
              ),
            ),
            const SizedBox(height: 20),
            // GridView
            Expanded(
              child: GridView.builder(
                itemCount: 4, // Jumlah item disesuaikan dengan desain
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/image.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Text('Gambar tidak ditemukan'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sound Wave Fest Early Bird',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text('16 May 2025'),
                              const SizedBox(height: 4),
                              const Text('Batu'),
                              const SizedBox(height: 4),
                              const Text('Rp. 160.000'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}