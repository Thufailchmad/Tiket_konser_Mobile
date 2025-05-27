import 'dart:convert';
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
  List<dynamic> _filteredData = []; // Untuk hasil pencarian
  final TextEditingController _searchController = TextEditingController();
  final formatRupiah =
      NumberFormat.currency(locale: "id_ID", symbol: "Rp", decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _data = getData();

    // Tambahkan listener ke pencarian
    _searchController.addListener(() {
      filterSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      setState(() {
        _dataList = List<dynamic>.from(body["data"]);
        _filteredData = _dataList; // Awalnya semua data ditampilkan
      });
      return _dataList;
    }

    throw Exception("Gagal mengambil data");
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = _dataList;
      } else {
        _filteredData = _dataList
            .where((item) =>
                item["name"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo-tiket2.png', height: 80),
            IconButton(
              icon: Icon(Icons.shopping_cart),
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
            // Kolom pencarian
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Cari Event...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // GridView
            Expanded(
              child: _filteredData.isEmpty
                  ? Center(child: Text("Tidak ditemukan"))
                  : GridView.builder(
                      itemCount: _filteredData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  builder: (context) => Deskripsi(
                                      id: _filteredData[index]["id"])),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    ipAddress + _filteredData[index]["images"],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Text('Gambar tidak ditemukan'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _filteredData[index]["name"],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(_filteredData[index]["expired"]),
                                      const SizedBox(height: 4),
                                      Text(_filteredData[index]["lokasi"]),
                                      const SizedBox(height: 4),
                                      Text(formatRupiah.format(
                                          _filteredData[index]["price"])),
                                    ],
                                  ),
                                ),
                              ],
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
