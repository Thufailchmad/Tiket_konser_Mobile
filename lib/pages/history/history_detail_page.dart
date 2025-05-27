import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HistoryDetailPage extends StatefulWidget {
  final int id;
  const HistoryDetailPage({super.key, required this.id});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  var data = {};
  final formatRupiah = NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 0);

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
    final req = await http.get(
        Uri.parse(ipAddress + "api/history/${widget.id}"),
        headers: header);
    final res = jsonDecode(req.body);
    if (req.statusCode == 202) {
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
        title: const Text(
          "Detail Riwayat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(0, 39, 180, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const MainPage())),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Kembali ke Beranda"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total: ${formatRupiah.format(data["total"])}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ipAddress + data["image"],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Gambar tidak ditemukan')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Status: ${data['status'] == 0 ? "Diproses" : data['status'] == 1 ? "Diterima" : "Ditolak"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: data['status'] == 0
                              ? Colors.orange
                              : data['status'] == 1
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Detail Tiket",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data["history_items"].length,
                    itemBuilder: (context, index) {
                      var ticket = data['history_items'][index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama: ${ticket['ticket']['name']}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Qty: ${ticket['qty']}'),
                              Text('Harga: ${formatRupiah.format(ticket['ticket']['price'])}'),
                              Text(
                                'Total: ${formatRupiah.format(ticket['ticket']['price'] * ticket['qty'])}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
