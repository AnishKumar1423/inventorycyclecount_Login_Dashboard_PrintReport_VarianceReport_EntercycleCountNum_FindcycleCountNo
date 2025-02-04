import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//import 'dashBoard.dart';
import 'enterQuantity.dart';

class CycleCountNumberFindButton extends StatefulWidget {
  const CycleCountNumberFindButton({super.key});

  @override
  _CycleCountNumberFindButtonState createState() =>_CycleCountNumberFindButtonState();
}

class _CycleCountNumberFindButtonState extends State<CycleCountNumberFindButton> {
  // Define controllers for the input fields
  TextEditingController cycleCountController = TextEditingController();
  List<int> cycleNumbers = [];
  List<int> filteredCycleNumbers = [];
  int? selectedCycle; // Now holds only one selected cycle count

  // Function to show error/success dialog
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

  // Modified to be called automatically when the screen loads
  @override
  void initState() {
    super.initState();
    findButton(
        context); // Automatically trigger the findButton function when the screen is loaded
  }

  Future<void> findButton(BuildContext context) async {
    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_GetDataF4140';

    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

    Map<String, dynamic> requestBody = {
      "Cycle Status 1": "20",
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
          List<dynamic>? rowset = serviceRequest["fs_DATABROWSE_F4140"]["data"]
          ["gridData"]["rowset"];

          // Check if rowset is empty or null
          if (rowset != null && rowset.isNotEmpty) {
            List<int> allCycleNumbers = rowset
                .where((item) => item.containsKey("F4140_CYNO"))
                .map<int>((item) => item["F4140_CYNO"] as int)
                .toList();

            setState(() {
              cycleNumbers = allCycleNumbers;
              filteredCycleNumbers = List.from(
                  cycleNumbers); // Initialize filtered list with all cycle numbers
            });
          } else {
            _showDialog(context, "No Data", "No records found.");
          }
        } else {
          _showDialog(context, "Error", "Failed to fetch valid data.");
        }
      } else {
        _showDialog(context, "Error",
            "Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (error) {
      _showDialog(context, "Error", "An error occurred: $error");
    }
  }

  // Filter data based on the entered cycle count number
  void filterData() {
    String cycleCount = cycleCountController.text;
    setState(() {
      filteredCycleNumbers = cycleNumbers
          .where((cycleNumber) => cycleNumber.toString().contains(cycleCount))
          .toList();
    });
  }

  // Toggle selection of a cycle number in the list (only one can be selected)
  void toggleCycleSelection(int cycleNumber) {
    setState(() {
      // If the user selects a different number, update it. If they select the same, deselect it.
      if (selectedCycle == cycleNumber) {
        selectedCycle = null; // Deselect if the same cycle is tapped
      } else {
        selectedCycle = cycleNumber; // Select new cycle
      }

      // Update the cycle count text field with selected cycle number
      if (selectedCycle != null) {
        cycleCountController.text = selectedCycle.toString();
      } else {
        cycleCountController.text = ''; // Clear the field if no selection
      }
    });
  }

  // Navigate to the next page with selected cycle number
  void navigateToNextPage(BuildContext context) {
    if (selectedCycle != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterCycleQuantityNumber(selectedCycle: selectedCycle!), // Passing selectedCycle
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
        title: const Text('Select Your Cycle Count'),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: <Widget>[
          // Cycle Count TextField
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            child: TextField(
              controller: cycleCountController,
              decoration: const InputDecoration(
                labelText: 'Enter Cycle Count Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                filterData(); // Trigger filtering on text change
              },
            ),
          ),
          const SizedBox(height: 20),

          // Display available cycle count list heading
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

          // Display filtered cycle numbers inside rectangular boxes in a ListView
          Expanded(
            child: ListView.builder(
              itemCount: filteredCycleNumbers.length,
              itemBuilder: (context, index) {
                int cycleNumber = filteredCycleNumbers[index];
                return GestureDetector(
                  onTap: () {
                    toggleCycleSelection(
                        cycleNumber); // Allow only one selection
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: selectedCycle == cycleNumber
                          ? Colors.cyan
                          : Colors.white30,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        'Cycle Count Number: $cycleNumber',
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedCycle == cycleNumber
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // OK Button
          ElevatedButton(
            onPressed: () => navigateToNextPage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
            ),
            child: const Text("OK",
                style: TextStyle(fontSize: 25, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}