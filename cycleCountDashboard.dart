import 'package:flutter/material.dart';
import 'package:inventorycyclecountak/reviewsCycleCountStatus.dart';
import 'package:inventorycyclecountak/updateCycleCount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ApproveCycleCount.dart';
import 'enterCycleCount.dart';
import 'main.dart';
import 'printCycleCount.dart';
import 'varianceReport.dart';

class CycleCountDashboard extends StatelessWidget {
  const CycleCountDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF244e6f),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back button icon color to black
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 100, 30, 50),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildGridButton(
              context,
              icon: Icons.receipt,
              label: 'Reviews of Cycle Count',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsCycleCountStatus()));
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.picture_as_pdf,
              label: 'Print Cycle Count',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrintCycleCountReport()));
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.edit,
              label: 'Enter Cycle Count',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CycleCountNumberFindButton()));
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.bar_chart,
              label: 'Run Variance Report',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VarianceReport()));
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.check,
              label: 'Approve/Cancel Cycle Count',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ApproveCycleCount()));
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.update,
              label: 'Update Cycle  Count',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateCycleCount()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF244e6f),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Clear shared preferences
                final prefs = await SharedPreferences.getInstance();
                //await prefs.clear();
                await prefs.remove('username'); // Remove saved username
                await prefs.remove('password'); // Remove saved password
                // await prefs.remove('serverUrl'); // Remove server URL

                // Navigate to login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => ServerConfigPage()),
                // );
              },
            ),
          ],
        );
      },
    );
  }
}
