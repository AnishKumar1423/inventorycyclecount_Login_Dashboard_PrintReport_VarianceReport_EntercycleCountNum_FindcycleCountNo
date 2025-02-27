import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_varienceReport';

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
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}"); // Debugging log
      print("Response Body: ${response.body}"); // Debugging log

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully submitted report')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not successfully submitted')),
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
        backgroundColor: Color(0xFF244e6f),
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
              border: Border.all(color: Color(0xFF244e6f), width: 2.0), // Outer border
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 70), // Reduced space from 100 to 20
                TextField(
                  controller: _controller1,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Business Unit',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
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