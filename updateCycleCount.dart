import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateCycleCountPage extends StatefulWidget {
  @override
  _UpdateCycleCountPageState createState() => _UpdateCycleCountPageState();
}

class _UpdateCycleCountPageState extends State<UpdateCycleCountPage> {
  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();

  Future<void> _submitReport() async {
    String cycleCountNumber = _controller1.text.trim();
    String glDate = _controller2.text.trim();

    if (cycleCountNumber.isEmpty || glDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_cycleCountUpdate';

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
      'ServiceRequest1': {
        'cycleCountNo': cycleCountNumber,
        'GLDate': glDate, // Ensure correct key name
      }
    });

    print("Request URL: $url");
    print("Request Headers: $headers");
    print("Request Body: $body"); // Debugging log

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey("ServiceRequest2") &&
            responseData["ServiceRequest2"].containsKey("fs_DATABROWSE_F4140") &&
            responseData["ServiceRequest2"]["fs_DATABROWSE_F4140"].containsKey("data") &&
            responseData["ServiceRequest2"]["fs_DATABROWSE_F4140"]["data"].containsKey("gridData") &&
            responseData["ServiceRequest2"]["fs_DATABROWSE_F4140"]["data"]["gridData"].containsKey("rowset") &&
            responseData["ServiceRequest2"]["fs_DATABROWSE_F4140"]["data"]["gridData"]["rowset"].isNotEmpty) {

          String cycleStatus = responseData["ServiceRequest2"]["fs_DATABROWSE_F4140"]["data"]["gridData"]["rowset"][0]["F4140_CYCS"];

          if (cycleStatus == "40") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed update (Status 40)')),
            );
          } else if (cycleStatus == "50") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully updated (Status 50)')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unexpected status: $cycleStatus')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid response format from server')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: HTTP ${response.statusCode}')),
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
      appBar: AppBar(title: const Text('Update Cycle Count')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _controller1,
              decoration: const InputDecoration(
                labelText: 'Enter Cycle Count Number',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller2,
              decoration: const InputDecoration(
                labelText: 'Enter GL Date',
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
