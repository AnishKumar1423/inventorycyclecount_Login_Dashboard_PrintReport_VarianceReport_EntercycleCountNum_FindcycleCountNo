import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsCycleCountStatus extends StatefulWidget {
  const ReviewsCycleCountStatus({super.key});

  @override
  _ReviewsCycleCountStatusState createState() =>
      _ReviewsCycleCountStatusState();
}

class _ReviewsCycleCountStatusState extends State<ReviewsCycleCountStatus> {
  final TextEditingController _cycleStatusFromController =
  TextEditingController();
  final TextEditingController _thruCycleStatusController =
  TextEditingController();


  final TextEditingController _cycleNoFilterController =
  TextEditingController();
  List<dynamic> apiData = [];
  List<dynamic> filteredData = [];

  Future<void> _submitReport() async {
    String cycleStatusFrom = _cycleStatusFromController.text;
    String thruCycleStatus = _thruCycleStatusController.text;

    if (cycleStatusFrom.isEmpty || thruCycleStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_reviewCycleCount';

    // Basic Authentication Credentials
    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "Cycle_Status_From": cycleStatusFrom,
      "Thru_Cycle_Status": thruCycleStatus
    });

    print("Request Body: $body");

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          apiData = responseData["FREQ_reviewCycleCount_1"] ?? [];
          filteredData = List.from(apiData); // Initially, no filter applied
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully submitted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not successfully submitted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e')),
      );
    }
  }

  void _filterData() {
    String cycleNoFilter = _cycleNoFilterController.text.trim().toLowerCase();

    setState(() {
      filteredData = apiData.where((item) {
        String cycleNumber = item["Cycle Number"].toString().toLowerCase();
        return cycleNumber.contains(cycleNoFilter);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews Cycle Count')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextFields for input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between items
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50, // Set a fixed height
                    child: TextField(
                      controller: _cycleStatusFromController,
                      decoration: const InputDecoration(
                        labelText: 'From Cycle Status',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Spacing between the text fields
                Expanded(
                  child: SizedBox(
                    height: 50, // Set a fixed height
                    child: TextField(
                      controller: _thruCycleStatusController,
                      decoration: const InputDecoration(
                        labelText: 'Thru Cycle Status',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row for Filter TextField and Find Button
            Row(
              children: [
                // Find Button with padding inside
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      child: Text('Find'),
                    ),
                  ),
                ),
                // Filter TextField for Cycle No with custom width, height, and padding
                Container(
                  width: 150, // Set the width of the filter box
                  height: 40, // Set the height of the filter box
                  padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding inside the filter box
                  child: TextField(
                    controller: _cycleNoFilterController,
                    decoration: const InputDecoration(
                      labelText: 'Find Cycle No',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (value) => _filterData(),
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10), // Spacing between filter and button
              ],
            ),
            const SizedBox(height: 10),

            // Optimized Table UI
            filteredData.isNotEmpty
                ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 8, // Reduced space between columns
                  dataRowMinHeight: 30, // Minimum row height
                  dataRowMaxHeight: 40, // Maximum row height
                  border: TableBorder.all(color: Colors.black),
                  columns: const [
                    DataColumn(
                      label: SizedBox(
                        width: 70, // Reduced width for compactness
                        child: Text('Cycle No', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 70, // Reduced width for compactness
                        child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 80, // Reduced width for compactness
                        child: Text('Count Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 90, // Reduced width for compactness
                        child: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  rows: filteredData.map((item) {
                    return DataRow(cells: [
                      DataCell(SizedBox(
                          width: 70,
                          child: Text(item["Cycle Number"].toString(), style: const TextStyle(fontSize: 12)))),
                      DataCell(SizedBox(
                          width: 70,
                          child: Text(item["Cycle Status"].toString(), style: const TextStyle(fontSize: 12)))),
                      DataCell(SizedBox(
                          width: 80,
                          child: Text(item["Count Date"].toString(), style: const TextStyle(fontSize: 12)))),
                      DataCell(SizedBox(
                          width: 90,
                          child: Text(item["Description"].toString(), style: const TextStyle(fontSize: 12)))),
                    ]);
                  }).toList(),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
