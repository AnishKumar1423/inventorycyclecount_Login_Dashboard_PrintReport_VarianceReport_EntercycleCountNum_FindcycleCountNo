import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnterCycleQuantityNumber extends StatefulWidget {
  final int selectedCycle;

  const EnterCycleQuantityNumber({super.key, required this.selectedCycle});

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
      "Cycle Number 1": widget.selectedCycle.toString(),
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
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Ensure that we are extracting data from the correct field
        var data = jsonResponse["DR_gettingDataa"] ?? [];

        setState(() {
          apiData = data; // Update apiData to hold the list from the API
        });
      } else {
        print("Error: Status code ${response.statusCode}");
      }
    } catch (error) {
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
                        // Text(
                        //   'Item ${index + 1}',
                        //   style: const TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 10),

                        // Display relevant fields from the API response
                        Text(
                          'Item Number  : ${item["2nd Item Number"]}',
                          style: const TextStyle(fontSize: 16 ,fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Business Unit : ${item["Business Unit [F4141]"]?.trim()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Location          : ${item["Location"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Lot Number     : ${item["Lot Serial Number"]?.trim()}',
                          style: const TextStyle(fontSize: 16),
                        ),

                        Text(
                          'Total Qty          : ${item["Total Quantity"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
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
