import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApproveCycleCount extends StatefulWidget {
  @override
  _ApproveCycleCountPageState createState() => _ApproveCycleCountPageState();
}

class _ApproveCycleCountPageState extends State<ApproveCycleCount> {
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
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_ApproveCycleCount';

    // Basic Authentication Credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'CycleCountNumber': cycleCountNumber,
    });

    print("Request Body: $body");

    try {
      final uri = Uri.parse(url);
      final request = http.Request('POST', uri)
        ..headers.addAll(headers)  // Add headers
        ..body = body;  // Add body

      // Send the request and get the response
      final response = await request.send();

      // Convert the StreamedResponse to a regular Response
      final responseData = await http.Response.fromStream(response);

      print("Response Status: ${responseData.statusCode}");
      print("Response Body: ${responseData.body}");

      if (responseData.statusCode == 200) {
        _controller2.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully submitted report')),
        );
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

  Future<void> _cancelCycleCount() async {
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
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_cancelCycleCount';

    // Basic Authentication Credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'Cycle_Number': cycleCountNumber,
    });

    print("Request Body: $body");

    try {
      final uri = Uri.parse(url);
      final request = http.Request('POST', uri)
        ..headers.addAll(headers)  // Add headers
        ..body = body;  // Add body

      // Send the request and get the response
      final response = await request.send();

      // Convert the StreamedResponse to a regular Response
      final responseData = await http.Response.fromStream(response);

      print("Response Status: ${responseData.statusCode}");
      print("Response Body: ${responseData.body}");

      if (responseData.statusCode == 200) {
        _controller2.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully canceled cycle count')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancel request failed: ${responseData.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling cycle count: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approve/Cancel Cycle Count',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF244e6f),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFF244e6f), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 45),
                TextField(
                  controller: _controller2,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'Enter Cycle Count Number',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit for Approve'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _cancelCycleCount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel Cycle Count'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
