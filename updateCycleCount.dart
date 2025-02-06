import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    const String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_cycleCountUpdate';

    // Basic Authentication Credentials
    const String authUsername = "ANISHKT";
    const String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

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
      final response =
      await http.post(Uri.parse(url), headers: headers, body: body);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData.containsKey("ServiceRequest2")) {
            final serviceRequest = responseData["ServiceRequest2"];
            final fsData = serviceRequest["fs_DATABROWSE_F4140"];
            if (fsData != null &&
                fsData.containsKey("data") &&
                fsData["data"].containsKey("gridData") &&
                fsData["data"]["gridData"].containsKey("rowset") &&
                fsData["data"]["gridData"]["rowset"].isNotEmpty) {
              String cycleStatus =
              fsData["data"]["gridData"]["rowset"][0]["F4140_CYCS"];

              String message;
              if (cycleStatus == "40") {
                message = 'Failed to update cycle count';
              } else if (cycleStatus == "50") {
                message = 'Successfully updated cycle count';
              } else {
                message = 'Unexpected status: $cycleStatus';
              }

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Cycle Count Number',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller2,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'GL Date (YYYY-MM-DD)',
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
