import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:konser_tiket/pages/history/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  var data = [];
  int total = 0;
  final formatRupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void getData() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final req =
        await http.get(Uri.parse(ipAddress + "api/chart"), headers: header);
    final res = jsonDecode(req.body);
    if (req.statusCode == 202) {
      setState(() {
        data = res["data"];
      });
      total = data.fold(0, (sum, ticket) {
        num qty = ticket["qty"];
        num price = ticket["ticket"]["price"];
        return sum + (qty * price).toInt();
      });
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  void pembayaran() async {
    final pref = await SharedPreferences.getInstance();
    String? token = pref.getString("token");
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = data.map((item) {
      return {'qty': item['qty'], 'ticketId': item['ticketId']};
    }).toList();

    var bodyInsert = {'ticket': body};

    final req = await http.post(
      Uri.parse(ipAddress + "api/history"),
      headers: header,
      body: jsonEncode(bodyInsert),
    );

    final res = jsonDecode(req.body);
    if (req.statusCode == 201) {
      final req2 = http.MultipartRequest(
        'POST',
        Uri.parse(ipAddress + "api/history/${res["historyId"]}"),
      );
      req2.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'User-Agent': 'android',
      });

      req2.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: _image!.path.split('/').last,
      ));

      var res2 = await req2.send();
      if (res2.statusCode == 202) {
        final resStr = await res2.stream.bytesToString();
        print("upload : $resStr");

        // Tambahkan popup sukses di sini
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Pembayaran Berhasil"),
              content:
                  const Text("Pembayaran Sedang Diproses. Terima kasih!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception("Gagal upload file");
      }
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Tiket"),
        backgroundColor: const Color.fromRGBO(0, 39, 180, 1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Informasi Nomor Rekening
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Transfer ke rekening berikut:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('BANK BNI - 1467707147 a.n. Bajo Sawah'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Gambar bukti transfer
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _image!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tidak ada gambar',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),

            const SizedBox(height: 16),

            // Total harga di bawah gambar
            Text(
              'Total Pembayaran: ${formatRupiah.format(total)}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),

            const SizedBox(height: 20),

            // Tombol pilih gambar
            SizedBox(
              width: 160,
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Upload Bukti Transfer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tombol konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: pembayaran,
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
