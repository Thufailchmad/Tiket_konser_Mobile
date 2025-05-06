import 'package:flutter/material.dart';
import 'package:konser_tiket/pages/payment/payment_page.dart';

class DetailPage extends StatelessWidget {
  final Map<String, String> concertDetails;

  const DetailPage({super.key, required this.concertDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,  // Warna AppBar yang lebih menarik
        title: Text(concertDetails['title']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 10, // Tambahkan bayangan untuk tampilan lebih modern
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar besar untuk menampilkan gambar konser dengan border radius
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  concertDetails['image']!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Judul konser dengan font besar dan tebal
              Text(
                concertDetails['title']!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              // Harga tiket
              Text(
                concertDetails['price']!,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              // Deskripsi konser
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                concertDetails['description']!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Lokasi konser
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${concertDetails['location']}',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Tombol proceed to payment
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,  // Warna tombol lebih berani
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Proceed to Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
