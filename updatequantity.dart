import 'package:flutter/material.dart';
import 'dart:convert';

import 'enterCycleCount.dart';

class EnterQuantity extends StatelessWidget {
  final List<Map<String, dynamic>> inventoryData = [
    {'item': 'ABC', 'lot': 123, 'available': 10, 'physical': 5, 'total': 5},
    {'item': 'XYZ', 'lot': 456, 'available': 0, 'physical': 0, 'total': 0},
    {'item': 'POU', 'lot': 987, 'available': 0, 'physical': 9, 'total': 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantity Update'),
        backgroundColor: Colors.cyan,
      ),
      body: Container(
        color: Colors.lightGreen[200],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue[700]),
                  children: const [
                    TableCell(child: Center(child: Text("Item No.", style: TextStyle(color: Colors.white)))),
                    TableCell(child: Center(child: Text("Lot No.", style: TextStyle(color: Colors.white)))),
                    TableCell(child: Center(child: Text("Available Qty", style: TextStyle(color: Colors.white)))),
                    TableCell(child: Center(child: Text("Physical Qty", style: TextStyle(color: Colors.white)))),
                    TableCell(child: Center(child: Text("Total Qty", style: TextStyle(color: Colors.white)))),
                  ],
                ),
                ...inventoryData.map((item) => TableRow(
                  children: [
                    TableCell(child: Center(child: Text(item['item'].toString()))),
                    TableCell(child: Center(child: Text(item['lot'].toString()))),
                    TableCell(child: Center(child: Text(item['available'].toString()))),
                    TableCell(child: Center(child: Text(item['physical'].toString()))),
                    TableCell(child: Center(child: Text(item['total'].toString()))),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 580),
            ElevatedButton(
              onPressed: () {

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => CycleCountNumberFindButton()),
                // );
                // Add action for cycle count
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Enter Cycle Count", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
