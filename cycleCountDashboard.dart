// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:inventorycyclecountak/reviewsCycleCountStatus.dart';
import 'package:inventorycyclecountak/updateCycleCount.dart';

import 'ApproveCycleCount.dart';
import 'enterCycleCount.dart'; // Import your pages here
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
          style: TextStyle(color: Colors.white, fontSize: 20), // Customize text style
        ),
        backgroundColor: Color(0xFF244e6f),
        elevation: 4, // Adjust shadow
      ),

      body: Container(
        padding: const EdgeInsets.fromLTRB(30, 120, 30, 50),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2, // Two items per row in the grid
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildGridButton(
              context,
              icon: Icons.receipt,
              label: 'Reviews of Cycle Count',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ReviewsCycleCountStatus()), // Replace with your actual page
                );
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.picture_as_pdf,
              label: 'Print Cycle count',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const PrintCycleCountReport()), // Replace with your actual page
                );
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.edit,
              label: 'Enter Cycle Count',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CycleCountNumberFindButton()), // Replace with your actual page
                );
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.bar_chart,
              label: 'Run Variance Report',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VarianceReport()), // Replace with your actual page
                );
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.check,
              label: 'Approve Cycle Count',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ApproveCycleCount()), // Replace with your actual page
                );
              },
            ),
            _buildGridButton(
              context,
              icon: Icons.update,
              label: 'Update Cycle  Count',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateCycleCount()), // Replace with your actual page
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // A helper function to build each grid item as a button
  Widget _buildGridButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
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
}


