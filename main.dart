// ignore_for_file: unused_import

import 'dart:convert'; // For JSON encoding

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cycleCountDashboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFF244e6f),  // The color you provided
              Color(0xFF244e6f),  // Same color for the gradient effect
              Color(0xFF244e6f),  // Same color for consistency
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80),
            Header(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: InputWrapper(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // const Text(
          //   "Inventory Cycle Count",
          //   style: TextStyle(color: Colors.white, fontSize: 18),
          //   textAlign: TextAlign.center,  // Ensures text is centered
          // ),
          // Displaying the image
          Image.asset(
            'assets/image/Anish.png',
            fit: BoxFit.contain, // or BoxFit.cover, depending on your layout
          ),
          const Text(
            "Inventory Cycle Count",
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,  // Ensures text is centered
          ),
        ],
      ),
    );
  }
}

class InputWrapper extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InputField(
              usernameController: usernameController,
              passwordController: passwordController,
            ),
          ),
          const SizedBox(height: 40),
          Button(
            usernameController: usernameController,
            passwordController: passwordController,
          ),
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const InputField(
      {required this.usernameController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              hintText: "Username",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
          child: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              hintText: "Password",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            obscureText: true, // Password field
          ),
        ),
      ],
    );
  }
}

class Button extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  Button({required this.usernameController, required this.passwordController});

  Future<void> login(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    // Validate that the username and password are not empty
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username and Password cannot be empty")),
      );
      return;
    }

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_gettingDataFromF55USER';

    // Basic Authentication Credentials
    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

    try {
      print(
          "Sending GET request to URL: $url?username=$username&password=$password");

      // Sending HTTP GET request with username and password as query parameters
      final response = await http.get(
        Uri.parse('$url?username=$username&password=$password'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      print("Response: ${response.body}");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data;
        try {
          data = json.decode(response.body);
          print("Decoded Data: $data");
        } catch (e) {
          print("Error parsing JSON: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid response format")),
          );
          return;
        }

        // Check if DR_gettingData contains meaningful data
        if (data['DR_gettingData'] != null &&
            data['DR_gettingData'].isNotEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Success")),
          );

          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CycleCountDashboard()),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid username or password")),
          );
        }
      } else {
        print("Server Error: ${response.statusCode}, Body: ${response.body}");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, try again later")),
        );
      }
    } catch (e) {
      print("Request Error: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await login(context);
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Color(0xFF244e6f),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
