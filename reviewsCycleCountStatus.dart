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
      final response =
      await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          apiData = responseData["FREQ_reviewCycleCount_1"] ?? [];
          filteredData = List.from(apiData); // Initially, no filter applied
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Find Status Successfully')),
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
      appBar: AppBar(
        title: const Text(
          'Reviews Cycle Count',
          style: TextStyle(color: Colors.white, fontSize: 20), // Customize text style
        ),
        backgroundColor: Color(0xFF244e6f),
        elevation: 4, // Adjust shadow
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for From Status, Thru Status, and Find button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120, // Adjust width for "From Status"
                  child: TextField(
                    controller: _cycleStatusFromController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'From Status',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 120, // Adjust width for "Thru Status"
                  child: TextField(
                    controller: _thruCycleStatusController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'Thru Status',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submitReport,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                    child: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Filter TextField below
            Row(
              children: [
                Container(
                  width: 275,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                    controller: _cycleNoFilterController,
                    decoration: const InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'Find Cycle No',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (value) => _filterData(),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Filter', // The text added in front of the input field
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Scrollable Table UI with alternating row colors and centered headers
            filteredData.isNotEmpty
                ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scrolling
                  child: DataTable(
                    columnSpacing: 8, // Reduced space between columns
                    dataRowMinHeight: 30, // Minimum row height
                    dataRowMaxHeight: 40, // Maximum row height
                    border: TableBorder.all(color: Colors.grey),
                    headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Color(0xFF244e6f),), // Header background color
                    columns: const [
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Cycle No',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Count Date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(filteredData.length,
                            (index) {
                          final item = filteredData[index];
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                // Alternating row colors
                                return index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[200]!;
                              },
                            ),
                            cells: [
                              DataCell(Container(
                                width: 30, // Fixed width for the 'Cycle No' column
                                alignment: Alignment.center,
                                child: Text(item["Cycle Number"].toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12)),
                              )),
                              DataCell(Container(
                                width: 170, // Fixed width for the 'Description' column
                                alignment: Alignment.center,
                                child: Text(
                                  item["Description"]
                                      ?.toString()
                                      .isNotEmpty ==
                                      true
                                      ? item["Description"].toString()
                                      : 'N/A', // Placeholder for empty descriptions
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1, // Avoid content overflow
                                ),
                              )),
                              DataCell(Container(
                                width: 40, // Fixed width for the 'Status' column
                                alignment: Alignment.center,
                                child: Text(item["Cycle Status"].toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12)),
                              )),
                              DataCell(Container(
                                width: 65, // Fixed width for the 'Count Date' column
                                alignment: Alignment.center,
                                child: Text(item["Count Date"].toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12)),
                              )),
                            ],
                          );
                        }),
                  ),
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
