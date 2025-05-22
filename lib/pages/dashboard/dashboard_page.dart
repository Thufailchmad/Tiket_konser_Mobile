import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konser_tiket/ipAddress.dart';
import 'package:konser_tiket/pages/chart/chart_page.dart';
import 'package:konser_tiket/ticket/deskripsi.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  late Future<List<dynamic>> _data;
  List<dynamic> _dataList = [];
  final formatRupiah =
      NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data = getData();
  }

  Future<List<dynamic>> getData() async {
    final Map<String, String> header = {
      'User-Agent': 'android',
      'Content-Type': 'application/json'
    };
    final response =
        await http.get(Uri.parse(ipAddress + "api/"), headers: header);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      print(body);
      setState(() {
        _dataList = List<dynamic>.from(body["data"]);
      });
      return List<dynamic>.from(body["data"]);
    }

    throw Exception("Gagal mengambil data");
  }

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
              color: Color.fromRGBO(0, 39, 180, 1),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChartPage()),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/sponsor.png',
              height: 150,
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
                itemCount:
                    _dataList.length, // Jumlah item disesuaikan dengan desain
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
                      child: InkWell(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Deskripsi(id: _dataList[index]["id"])),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                ipAddress + _dataList[index]["images"],
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
                                  Text(
                                    _dataList[index]["name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_dataList[index]["expired"]),
                                  const SizedBox(height: 4),
                                  Text(_dataList[index]["lokasi"]),
                                  const SizedBox(height: 4),
                                  Text(formatRupiah
                                      .format(_dataList[index]["price"])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
