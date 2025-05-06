import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'title': 'EARLY BIRD - SWF 2025', 'amount': 'Rp. 160.000', 'status': 'Success', 'date': '03/04/2025'},
      {'title': 'EARLY BIRD - SWF 2025', 'amount': 'Rp. 800.000', 'status': 'Success', 'date': '07/04/2025'},
      {'title': 'EARLY BIRD - SWF 2025', 'amount': 'Rp. 320.000', 'status': 'Failed', 'date': '12/04/2025'},
      {'title': 'EARLY BIRD - SWF 2025', 'amount': 'Rp. 160.000', 'status': 'Success', 'date': '15/04/2025'},
    ];

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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16), 
            Expanded(
              child: ListView.builder(
                itemCount: orders.length, 
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['title']!,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(order['amount']!, style: TextStyle(fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Status: ${order['status']!}', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          Text('Date: ${order['date']!}', style: TextStyle(fontSize: 12, color: Colors.grey)),
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