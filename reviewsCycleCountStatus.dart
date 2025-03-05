import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();

    // Set default values
    _cycleStatusFromController.text = "10";
    _thruCycleStatusController.text = "60";

    // Auto-fetch data after the screen builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitReport();
    });
  }


  Future<void> _submitReport() async {
    String cycleStatusFrom = _cycleStatusFromController.text;
    String thruCycleStatus = _thruCycleStatusController.text;

    if (cycleStatusFrom.isEmpty || thruCycleStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    String? serverUrl = prefs.getString('serverUrl');

    if (username == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No credentials found. Please log in.')),
      );
      return;
    }

    if (serverUrl == null || serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL not configured")),
      );
      return;
    }

    String url =
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_reviewCycleCount';
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
          filteredData = List.from(apiData);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Loaded Successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

  Widget _buildTextField(TextEditingController controller, String labelText,
      {Function(String)? onChanged}) {
    return SizedBox(
      width: labelText == 'Find Cycle Count No' ? 260 : 120, // Increased width
      height: 40,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          fillColor: Colors.white,
          labelText: labelText,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews Cycle Count',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color(0xFF244e6f),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Input Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextField(_cycleStatusFromController, 'From Status'),
                _buildTextField(_thruCycleStatusController, 'Thru Status'),
                ElevatedButton(
                  onPressed: _submitReport,
                  child: const Icon(Icons.search, size: 20.0),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Find Cycle Count No Field
            Row(
              children: [
                _buildTextField(
                  _cycleNoFilterController,
                  'Find Cycle Count No',
                  onChanged: (value) => _filterData(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Scrollable Table UI
            filteredData.isNotEmpty
                ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 8,
                    dataRowMinHeight: 30,
                    dataRowMaxHeight: 40,
                    border: TableBorder.all(color: Colors.grey),
                    headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => const Color(0xFF244e6f),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Cycle No',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Count Date',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(filteredData.length,
                            (index) {
                          final item = filteredData[index];
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                return index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[200]!;
                              },
                            ),
                            cells: [
                              DataCell(Text(item["Cycle Number"].toString())),
                              DataCell(Text(
                                item["Description"]?.toString() ?? 'N/A',
                                maxLines: 1,
                              )),
                              DataCell(
                                  Text(item["Cycle Status"].toString())),
                              DataCell(Text(item["Count Date"].toString())),
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
