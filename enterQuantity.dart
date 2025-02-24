import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EnterCycleQuantityNumber extends StatefulWidget {
  final int selectedCycle;

  const EnterCycleQuantityNumber({super.key, required this.selectedCycle});

  @override
  _EnterQuantityState createState() => _EnterQuantityState();
}

class _EnterQuantityState extends State<EnterCycleQuantityNumber> {
  List<dynamic> apiData = [];
  List<dynamic> filteredData = [];
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  Map<int, TextEditingController> qtyControllers = {};

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
        filterData();
      });
    });
  }

  Future<void> fetchData() async {

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

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_gettingDataFromF4141';

    //Basic Authentication
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Map<String, dynamic> requestBody = {
      "Cycle Number 1": widget.selectedCycle.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var data = jsonResponse["DR_gettingDataa"] ?? [];

        setState(() {
          apiData = data.map((item) {
            item['Entered Quantity'] = '';
            return item;
          }).toList();

          filteredData = apiData;
          qtyControllers = {
            for (int i = 0; i < apiData.length; i++) i: TextEditingController(),
          };
        });
      } else {
        print("Error: Status code ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void filterData() {
    setState(() {
      if (_searchQuery.isEmpty) {
        filteredData = apiData;
      } else {
        filteredData = apiData
            .where((item) => item["2nd Item Number"]
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

// Function to update the total quantity when the button is clicked
  void updateTotalQuantity(int index) {
    String enteredQty = qtyControllers[index]?.text ?? '';
    if (enteredQty.isEmpty || int.tryParse(enteredQty) == null || int.parse(enteredQty) <= 0) {
      print("Invalid quantity entered");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    var item = filteredData[index];
    double totalQuantity = double.tryParse(item["Total Quantity"].toString()) ?? 0.0;

    double enteredQuantity = double.tryParse(enteredQty) ?? 0.0;

    setState(() {
      filteredData[index]['Entered Quantity'] = enteredQty;
      apiData[index]['Entered Quantity'] = enteredQty;

      // Update total quantity as an integer
      filteredData[index]['Total Quantity'] = (totalQuantity + enteredQuantity).toInt().toString();
      apiData[index]['Total Quantity'] = filteredData[index]['Total Quantity'];
    });
  }


  Future<void> submitQuantity(int index) async {

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

    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_enterQuantityP41240';
    String enteredQty = qtyControllers[index]?.text ?? '';

  //Basic Authentication

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    var item = filteredData[index];
    String originalQuantity = item['Entered Quantity']; // Save original quantity

    updateTotalQuantity(index); // Update total quantity when button is clicked
    String cycleStatus = int.tryParse(enteredQty) != null && int.parse(enteredQty) > 0 ? "30" : "20";

    Map<String, dynamic> requestBody = {
      "Second_Item_Number": item["2nd Item Number"],
      "Branch__Plant": item["Business Unit [F4141]"],
      "Lot_Serial": item["Lot Serial Number"],
      "Cycle_Status": cycleStatus,
      "Select_Row": "1",
      "Update_Row": "1",
      "Cycle_Number": widget.selectedCycle,
      "Quantity": enteredQty,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['jde__status'] == "SUCCESS") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quantity successfully updated for Item ${item["2nd Item Number"]}')),
          );
          qtyControllers[index]?.clear(); // Clear the input field
        } else {
          setState(() {
            filteredData[index]['Entered Quantity'] = originalQuantity;
            apiData[index]['Entered Quantity'] = originalQuantity;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update quantity for Item ${item["2nd Item Number"]}')),
          );
        }
      } else {
        setState(() {
          filteredData[index]['Entered Quantity'] = originalQuantity;
          apiData[index]['Entered Quantity'] = originalQuantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity. Status code: ${response.statusCode}')),
        );
      }
    } catch (error) {
      setState(() {
        filteredData[index]['Entered Quantity'] = originalQuantity;
        apiData[index]['Entered Quantity'] = originalQuantity;
      });
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating quantity. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Quantity for Cycle ${widget.selectedCycle}' ,
          style: TextStyle(color: Colors.white, fontSize: 20), // Customize text style
        ),
        backgroundColor: Color(0xFF244e6f),
        elevation: 4, // Adjust shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back button icon color to black
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),

      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF244e6f),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                'Cycle Count Number: ${widget.selectedCycle}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Enter Item Number to search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredData.isNotEmpty
                ? ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                var item = filteredData[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          'Item Number  : ${item["2nd Item Number"]}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Business Unit : ${item["Business Unit [F4141]"]?.trim()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Location          : ${item["Location"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Lot Number     : ${item["Lot Serial Number"]?.trim()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'JDE Quantity   : ${item["Total Prim Qty on Hand"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Total Qty          : ${item["Total Quantity"]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 45),
                            SizedBox(
                              width: 80,
                              child: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: TextFormField(
                                  controller: qtyControllers[index],
                                  decoration: const InputDecoration(
                                    hintText: 'Qty',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => submitQuantity(index),
                          child: const Text('Update Quantity'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}