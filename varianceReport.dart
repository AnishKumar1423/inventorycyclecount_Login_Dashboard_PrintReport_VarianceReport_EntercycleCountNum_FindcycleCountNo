import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'cycleCountDashboard.dart';

class VarianceReport extends StatefulWidget {
  @override
  _VarianceReportPageState createState() => _VarianceReportPageState();
}

class _VarianceReportPageState extends State<VarianceReport> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  Future<void> _submitReport() async {
    String businessUnit = _controller1.text;
    String cycleCountNumber = _controller2.text;

    if (businessUnit.isEmpty || cycleCountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields')),
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
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_varienceReport';

    // Basic Authentication Credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'businessUnit': businessUnit,
      'cycleCountNo': cycleCountNumber, // Ensure correct key name
    });

    print("Request Body: $body"); // Debugging log

    try {
      // Create a request object
      final uri = Uri.parse(url);
      final request = http.Request('POST', uri)
        ..headers.addAll(headers)  // Add headers
        ..body = body;  // Add body

      // Send the request and get the response
      final response = await request.send();

      // Convert the StreamedResponse to a regular Response
      final responseData = await http.Response.fromStream(response);

      print("Response Status: ${responseData.statusCode}"); // Debugging log
      print("Response Body: ${responseData.body}"); // Debugging log

      if (responseData.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully submitted report')),
        );
        // Wait for the snackbar to show for a moment, then navigate back
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CycleCountDashboard()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submission failed: ${responseData.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Variance Report',
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
                const SizedBox(height: 45), // Reduced space from 100 to 20
                TextField(
                  controller: _controller1,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Business Unit',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller2,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Cycle Count Number',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),

                const SizedBox(height: 20), // Reduced space from 90 to 20
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF244e6f), // Set the background color
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
