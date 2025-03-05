import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cycleCountDashboard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: checkServerUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == null) {
              return ServerConfigPage();
            } else {
              // Proceed to check session
              return FutureBuilder<bool>(
                future: checkSession(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return snapshot.data == true ? const CycleCountDashboard() : const LoginPage();
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<String?> checkServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('serverUrl');
  }

  Future<bool> checkSession(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') != null && prefs.getString('password') != null;
  }
}

// Server Configuration Page
class ServerConfigPage extends StatelessWidget {
  final TextEditingController serverUrlController = TextEditingController();

  ServerConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFF244e6f),
              Color(0xFF244e6f),
              Color(0xFF244e6f),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 80),
            Header(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "AIS Server Manager",
                        style: TextStyle(
                          color: Color(0xFF244e6f),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Icon(Icons.settings, size: 60, color: Color(0xFF244e6f)),
                      const SizedBox(height: 5),
                      TextField(
                        controller: serverUrlController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          labelText: 'Enter Server URL',
                          hintText: '103.41.100.86:7018',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF244e6f),
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          String url = serverUrlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a URL')),
                            );
                            return;
                          }

                          // Save only the server URL without clearing other preferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('serverUrl', url);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Server URL saved successfully')),
                          );

                          // Restart the app to apply the new server URL
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                        },


                        child: const Text(
                          "GO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF244e6f),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white), // Exit icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ServerConfigPage()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFF244e6f),
              Color(0xFF244e6f),
              Color(0xFF244e6f),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Header(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
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

// Header widget for login
class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/image/Anish.png',
            fit: BoxFit.contain,
          ),
          const Text(
            "JD Edwards EnterpriseOne",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Text(
            "Inventory Cycle Count",
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// InputWrapper for username and password fields
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

// InputField for username and password TextField
class InputField extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  const InputField({required this.usernameController, required this.passwordController});

  @override
  _InputFieldState createState() => _InputFieldState();
}

bool _obscureText = true;

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: TextField(
            controller: widget.usernameController,
            decoration: const InputDecoration(
              hintText: "Username",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.person,  // User icon
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: TextField(
            controller: widget.passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Button for the login process
class Button extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  Button({required this.usernameController, required this.passwordController});

  // Save user session to SharedPreferences
  Future<void> saveUserSession(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<void> login(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username and Password cannot be empty")),
      );
      return;
    }

    // Retrieve the server URL from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? serverUrl = prefs.getString('serverUrl');

    if (serverUrl == null || serverUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server URL not configured")),
      );
      return;
    }

    String url = 'http://$serverUrl/jderest/v3/orchestrator/ORCH_getUserIDPassword';

    // Use the user-entered credentials for authentication
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      print("Sending GET request to: $url?username=$username&password=$password");

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
        var data = json.decode(response.body);
        print("Decoded Data: $data");

        if (data['ServiceRequest1']?['result']?['errors'] != null) {
          var errorList = data['ServiceRequest1']['result']['errors'];
          for (var error in errorList) {
            if (error.containsKey("szerror")) {
              String errorCode = error["szerror"];
              String errorMessage = getErrorMessage(errorCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login Failed: $errorMessage")),
              );
              return;
            }
          }
        }

        if (data['ServiceRequest1']?['result']?['output'] != null) {
          var output = data['ServiceRequest1']['result']['output'];

          String? apiUsername;
          String? apiPassword;

          for (var item in output) {
            if (item['name'] == "szUserid") {
              apiUsername = item['value'];
            } else if (item['name'] == "szUserpassword") {
              apiPassword = item['value'];
            }
          }

          if (apiUsername == username && apiPassword == password) {
            await saveUserSession(username, password);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login Success")),
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CycleCountDashboard()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid username or password")),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error, try again later")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case "0261":
        return "Invalid username or password.";
      case "9999":
        return "System error. Please try again later.";
      default:
        return "Unknown error occurred.";
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
        margin: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: const Color(0xFF244e6f),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "SIGN IN",
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
