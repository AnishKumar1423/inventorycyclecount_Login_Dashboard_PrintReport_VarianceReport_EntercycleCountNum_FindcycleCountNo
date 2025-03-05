import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCycleCount extends StatefulWidget {
  @override
  _UpdateCycleCountState createState() => _UpdateCycleCountState();
}

class _UpdateCycleCountState extends State<UpdateCycleCount> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  Timer? _timer;
  int _remainingTime = 0; // To track the countdown
  bool _isSubmitting = false; // To disable the button while waiting

  Future<void> _submitReport() async {
    String cycleCountNumber = _controller1.text.trim();
    String glDate = _controller2.text.trim();

    if (cycleCountNumber.isEmpty || glDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

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
        'http://$serverUrl/jderest/v3/orchestrator/ORCH_cycleCountUpdate';

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
      setState(() {
        _isSubmitting = true; // Disable submit button
        _remainingTime = 20; // Start 20 sec countdown
      });

      // Start the countdown timer
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isSubmitting = false; // Re-enable the button after 20 seconds
          });
        }
      });

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

              if (cycleStatus == "50") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully updated cycle count')),
                );
              } else if (cycleStatus == "40") {
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
        _controller2.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Cycle Count',
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
                  readOnly: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    labelText: 'GL Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => _selectDate(context),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                _isSubmitting
                    ? Text("Please wait $_remainingTime sec", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                    : ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF244e6f),
                      foregroundColor: Colors.white),
                  child: const Text('Submit'),
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