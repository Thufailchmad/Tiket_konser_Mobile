import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late var data = [];
  late int total = 0;

  @override
  void initState() {
    // TODO: implement initState
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
      print(res);
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
    var body = [];
    for (var item in data) {
      body.add({'qty': item['qty'], 'ticketId': item['ticketId']});
    }
    var bodyInsert = {'ticket': body};
    print(bodyInsert);
    final req = await http.post(Uri.parse(ipAddress + "api/history"),
        headers: header, body: jsonEncode(bodyInsert));
    final res = jsonDecode(req.body);
    if (req.statusCode == 201) {
      print(res);
      final req2 = await http.MultipartRequest(
        'POST',
        Uri.parse(ipAddress + "api/history/${res["historyId"]}"),
      );
      req2.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'User-Agent': 'android',
      });

      req2.files.add(await http.MultipartFile.fromPath('image', _image!.path,
          filename: _image!.path.split('/').last));
      var res2 = await req2.send();
      if (res2.statusCode == 202) {
        final resStr = await res2.stream.bytesToString();
        print("upload : ${resStr}");
      } else {
        print(res2.statusCode);
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
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text(
              'Total: Rp $total',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _image!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'tidak ada gambar',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: pickImage,
                child: const Text('Pilih Gambar'),
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
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: pembayaran,
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // warna background
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
