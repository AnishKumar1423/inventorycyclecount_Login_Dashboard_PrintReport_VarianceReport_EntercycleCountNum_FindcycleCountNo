// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:inventorycyclecountak/updateCycleCount.dart';

import 'enterCycleCount.dart'; // Import your pages here
import 'printCycleCount.dart';
import 'varianceReport.dart';

class CycleCountDashboard extends StatelessWidget {
  const CycleCountDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.cyan,
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
                          ApproveCycleCountPage()), // Replace with your actual page
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
                          ApproveCycleCountPage()), // Replace with your actual page
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
                          UpdateCycleCountPage()), // Replace with your actual page
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
          color: Colors.cyan[500],
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

// Dummy pages for each button
class EnterQuantity extends StatelessWidget {
  const EnterQuantity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Cycle Count Quantity')),
      body: const Center(child: Text('Enter Cycle Count Page')),
    );
  }
}

class VarianceReportPage extends StatelessWidget {
  const VarianceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Variance Report')),
      body: const Center(child: Text('Variance Report Page')),
    );
  }
}

class ApproveCycleCountPage extends StatelessWidget {
  const ApproveCycleCountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Cycle Count')),
      body: const Center(child: Text('Approve Cycle Count Page')),
    );
  }
}

