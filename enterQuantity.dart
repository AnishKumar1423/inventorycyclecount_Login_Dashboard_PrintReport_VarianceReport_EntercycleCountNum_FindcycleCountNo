import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnterCycleQuantityNumber extends StatefulWidget {
  final int selectedCycle;

  EnterCycleQuantityNumber({required this.selectedCycle});

  @override
  _EnterQuantityState createState() => _EnterQuantityState();
}

class _EnterQuantityState extends State<EnterCycleQuantityNumber> {
  List<dynamic> apiData = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data from the API when the screen loads
  }

  // Function to fetch data from the API
  Future<void> fetchData() async {
    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_gettingDataFromF4141';

    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

    // Prepare request body to send the selected cycle number
    Map<String, dynamic> requestBody = {
      "Cycle Number 1": widget.selectedCycle,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          apiData = jsonDecode(response.body)["data"] ?? [];
        });
      } else {
        // Handle error here if needed
        print("Error: Status code ${response.statusCode}");
      }
    } catch (error) {
      // Handle any error occurred during the API call
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Quantity for Cycle ${widget.selectedCycle}'),
      ),
      body: Column(
        children: <Widget>[
          // Display selected cycle count in a non-editable square box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.cyan, // Background color for the box
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                'Cycle Count Number: ${widget.selectedCycle}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Display a ListView to show the entire JSON data from the API
          Expanded(
            child: apiData.isNotEmpty
                ? ListView.builder(
              itemCount: apiData.length,
              itemBuilder: (context, index) {
                var item = apiData[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Item ${index + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Iterate through all key-value pairs in the map
                        ...item.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}