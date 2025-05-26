import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:konser_tiket/pages/payment/payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late var data = [];

  @override
  void initState() {
    super.initState();
    getData();
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
      print(res['data']);
      setState(() {
        data = res["data"];
      });
    } else {
      throw Exception("Gagal mendapatkan data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Tiket"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(0, 39, 180, 1),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[100],
        child: Column(
          children: [
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.home,
                  color: Color.fromRGBO(0, 39, 180, 1),
                ),
                title: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: const Text(
                  "Lanjut ke Pembayaran",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentPage()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text("Keranjang kosong"))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[100],
                              child: Image.network(
                                ipAddress + item['ticket']['images'],
                              ),
                            ),
                            title: Text(item['ticket']['name'] ?? 'Tiket'),
                            subtitle: Text("Qty: ${item['qty'] ?? 1}"),
                            trailing: Text(
                              "Rp${item['ticket']['price'] ?? 0}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
