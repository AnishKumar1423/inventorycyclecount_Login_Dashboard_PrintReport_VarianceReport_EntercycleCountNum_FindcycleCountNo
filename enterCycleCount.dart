import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'enterQuantity.dart';

class CycleCountNumberFindButton extends StatefulWidget {
  const CycleCountNumberFindButton({super.key});

  @override
  _CycleCountNumberFindButtonState createState() => _CycleCountNumberFindButtonState();
}

class _CycleCountNumberFindButtonState extends State<CycleCountNumberFindButton> {
  TextEditingController cycleCountController = TextEditingController();
  List<int> cycleNumbers = [];
  List<int> filteredCycleNumbers = [];
  int? selectedCycle;

  @override
  void initState() {
    super.initState();
    findButton(context);
  }

  // Function to show a dialog
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to fetch cycle count numbers for status "20" and "30"
  Future<void> findButton(BuildContext context) async {

    // Retrieve the stored username and password from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username == null || password == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No credentials found. Please log in.')),
      );
      return;
    }
// Retrieve the server URL from SharedPreferences
    final prefs1 = await SharedPreferences.getInstance();
    String? serverUrl = prefs1.getString('serverUrl');

    if (serverUrl == null || serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL not configured")),
      );
      return;
    }

    String url =
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_GetDataF4140';
  //Basic Authentication
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    List<int> allCycleNumbers = [];

    for (String status in ["20", "30"]) {
      Map<String, dynamic> requestBody = {
        "Cycle Status 1": status,
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
          var serviceRequest = jsonResponse["ServiceRequest1"];

          if (serviceRequest != null &&
              serviceRequest["fs_DATABROWSE_F4140"] != null &&
              serviceRequest["fs_DATABROWSE_F4140"]["data"] != null &&
              serviceRequest["fs_DATABROWSE_F4140"]["data"]["gridData"] != null) {
            List<dynamic>? rowset = serviceRequest["fs_DATABROWSE_F4140"]["data"]["gridData"]["rowset"];

            if (rowset != null && rowset.isNotEmpty) {
              List<int> cycleNumbers = rowset
                  .where((item) => item.containsKey("F4140_CYNO"))
                  .map<int>((item) => item["F4140_CYNO"] as int)
                  .toList();

              allCycleNumbers.addAll(cycleNumbers);
            }
          }
        } else {
          _showDialog(context, "Error", "Failed to fetch data. Status Code: ${response.statusCode}");
        }
      } catch (error) {
        _showDialog(context, "Error", "An error occurred: $error");
      }
    }

    if (allCycleNumbers.isNotEmpty) {
      setState(() {
        cycleNumbers = allCycleNumbers.toSet().toList(); // Remove duplicates
        filteredCycleNumbers = List.from(cycleNumbers);
      });
    } else {
      _showDialog(context, "No Data", "No records found.");
    }
  }

  // Filter cycle numbers based on user input
  void filterData() {
    String cycleCount = cycleCountController.text;
    setState(() {
      filteredCycleNumbers = cycleNumbers
          .where((cycleNumber) => cycleNumber.toString().contains(cycleCount))
          .toList();
    });
  }

  // Toggle selection of a cycle number
  void toggleCycleSelection(int cycleNumber) {
    setState(() {
      if (selectedCycle == cycleNumber) {
        selectedCycle = null;
      } else {
        selectedCycle = cycleNumber;
      }

      // Update text field with selected cycle number
      cycleCountController.text = selectedCycle?.toString() ?? '';
    });
  }

  // Navigate to the next page with the selected cycle number
  void navigateToNextPage(BuildContext context) {
    if (selectedCycle != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterCycleQuantityNumber(selectedCycle: selectedCycle!),
        ),
      );
    } else {
      _showDialog(context, "Error", "Please select a cycle number.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Cycle Count Number',
          style: TextStyle(color: Colors.white, fontSize: 20), // Customize text style
        ),
        backgroundColor: Color(0xFF244e6f),
        elevation: 4, // Adjust shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back button icon color to black
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: TextField(
              controller: cycleCountController,
              decoration: const InputDecoration(
                labelText: 'Enter Cycle Count Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                filterData();
              },
            ),
          ),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Available Cycle Count Numbers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: filteredCycleNumbers.length,
              itemBuilder: (context, index) {
                int cycleNumber = filteredCycleNumbers[index];
                return GestureDetector(
                  onTap: () {
                    toggleCycleSelection(cycleNumber);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: selectedCycle == cycleNumber ? Color(0xFF244e6f) : Colors.white30,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        'Cycle Count Number: $cycleNumber',
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedCycle == cycleNumber ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () => navigateToNextPage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF244e6f),
              padding: const EdgeInsets.symmetric(horizontal: 30),
            ),
            child: const Text("OK", style: TextStyle(fontSize: 25, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
