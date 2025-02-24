import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UpdateCycleCount extends StatefulWidget {
  @override
  _UpdateCycleCountState createState() => _UpdateCycleCountState();
}

class _UpdateCycleCountState extends State<UpdateCycleCount> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  Future<void> _submitReport() async {
    String cycleCountNumber = _controller1.text.trim();
    String glDate = _controller2.text.trim();

    if (cycleCountNumber.isEmpty || glDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

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

    const String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_cycleCountUpdate';

    // Basic Authentication Credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'cycleCountNumber': cycleCountNumber,
      'GLDate': glDate,
    });

    print("Request Body: $body");

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData.containsKey("ServiceRequest3")) {
            final serviceRequest = responseData["ServiceRequest3"];
            final fsData = serviceRequest["fs_DATABROWSE_F4140"];

            if (fsData != null &&
                fsData.containsKey("data") &&
                fsData["data"].containsKey("gridData") &&
                fsData["data"]["gridData"].containsKey("rowset") &&
                fsData["data"]["gridData"]["rowset"].isNotEmpty) {
              String cycleStatus = fsData["data"]["gridData"]["rowset"][0]["F4140_CYCS"];


              await Future.delayed(const Duration(seconds: 20)); // Random delay between 10 to 30 seconds
              print("Delay to completed after 20 Second");

              if (cycleStatus == "50") {
                // If "50", show success
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully updated cycle count')),
                );
              } else if (cycleStatus == "40") {
                //If "40" , show failed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update cycle count')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: Unexpected cycle status: $cycleStatus')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid response structure')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unexpected response from server')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing response: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submission failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    }
  }

  // Function to show the DatePicker dialog and set the selected date in the text field
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        // Format the date to MM/DD/YYYY format before setting it in the text field
        _controller2.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Cycle Count',
          style: TextStyle(color: Colors.white, fontSize: 20), // Customize text style
        ),
        backgroundColor: const Color(0xFF244e6f),
        elevation: 4, // Adjust shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back button icon color to black
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Container(
        color: Colors.white, // Background color
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // Inner container color
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              border: Border.all(color: const Color(0xFF244e6f), width: 2.0), // Outer border
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 70), // Reduced space from 100 to 20
                TextField(
                  controller: _controller1,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Cycle Count Number',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: _controller2,
                  keyboardType: TextInputType.datetime,
                  readOnly: true, // Makes the TextField non-editable
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'GL Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => _selectDate(context), // Open date picker when tapped
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                ),



                const SizedBox(height: 20), // Reduced space from 90 to 20
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF244e6f), // Set the background color
                      foregroundColor: Colors.white
                  ),
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 50), // Reduced space from 90 to 20
              ],
            ),
          ),
        ),
      ),
    );
  }
}
