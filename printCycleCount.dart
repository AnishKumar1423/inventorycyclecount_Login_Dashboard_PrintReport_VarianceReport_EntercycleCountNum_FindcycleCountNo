import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrintCycleCountReport extends StatefulWidget {
  const PrintCycleCountReport({super.key});

  @override
  _PrintCycleCountReportPageState createState() =>
      _PrintCycleCountReportPageState();
}

class _PrintCycleCountReportPageState
    extends State<PrintCycleCountReport> {
  TextEditingController _controller2 = TextEditingController();

  Future<void> _submitReport() async {
    String cycleCountNumber = _controller2.text.trim();

    if (cycleCountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in fields')),
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
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_printCycleCount';

    // Use the retrieved credentials for Basic Authentication
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'cycleCountNumber': cycleCountNumber,
    });

    print("Request Body: $body");

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully submitted report')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Print Cycle Count Report',
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
                const SizedBox(height: 90), // Reduced space from 100 to 20
                TextField(
                  controller: _controller2,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Cycle Count Number',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 30), // Reduced space from 90 to 20
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF244e6f), // Set the background color
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 60), // Reduced space from 90 to 20
              ],
            ),
          ),
        ),
      ),
    );
  }
}
