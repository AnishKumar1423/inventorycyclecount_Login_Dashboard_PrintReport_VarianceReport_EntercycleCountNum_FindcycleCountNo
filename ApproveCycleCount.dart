import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApproveCycleCount extends StatefulWidget {

  @override
  _PrintCycleCountReportPageState createState() => _PrintCycleCountReportPageState();
}

class _PrintCycleCountReportPageState extends State<ApproveCycleCount> {

  TextEditingController _controller2 = TextEditingController();

  Future<void> _submitReport() async {
    String cycleCountNumber = _controller2.text.trim();

    if (cycleCountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in fields')),
      );
      return;
    }

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_ApproveCycleCount';

    // Basic Authentication Credentials
    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

    final headers = {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'CycleCountNumber': cycleCountNumber,
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
      appBar: AppBar(title: const Text('Print Cycle Count Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Enter Cycle Count Number',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReport,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
