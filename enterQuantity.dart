import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnterCycleQuantityNumber extends StatefulWidget {
  final int selectedCycle;

  const EnterCycleQuantityNumber({super.key, required this.selectedCycle});

  @override
  _EnterQuantityState createState() => _EnterQuantityState();
}

class _EnterQuantityState extends State<EnterCycleQuantityNumber> {
  List<dynamic> apiData = [];
  List<dynamic> filteredData = [];
  Map<int, TextEditingController> quantityControllers = {};
  TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String url =
        'http://192.168.0.36:7018/jderest/v3/orchestrator/ORCH_gettingDataFromF4141';

    String authUsername = "ANISHKT";
    String authPassword = "Kirti@321";
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$authUsername:$authPassword'))}';

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
          apiData = data;
          filteredData = List.from(apiData);
          quantityControllers.clear();

          for (var i = 0; i < apiData.length; i++) {
            quantityControllers[i] = TextEditingController(
                text: apiData[i]["Total Quantity"]?.toString() ?? '');
          }
        });
      } else {
        print("Error: Status code ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void filterItems(String query) {
    setState(() {
      filteredData = apiData
          .where((item) => item["2nd Item Number"]
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  void submitQuantity(int index, int originalIndex) {
    String updatedQuantity = quantityControllers[originalIndex]?.text ?? "";

    if (updatedQuantity.isNotEmpty) {
      setState(() {
        apiData[originalIndex]["Total Quantity"] = updatedQuantity;
        filteredData[index]["Total Quantity"] = updatedQuantity;
      });

      print("Updated Quantity for item $originalIndex: $updatedQuantity");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Quantity for Cycle  ${widget.selectedCycle}'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: filterController,
              decoration: InputDecoration(
                labelText: 'Filter By Item Number',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    filterController.clear();
                    filterItems('');
                  },
                ),
              ),
              onChanged: filterItems,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                'Cycle Count Number : ${widget.selectedCycle}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: filteredData.isNotEmpty
                ? ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                var item = filteredData[index];
                int originalIndex = apiData.indexOf(item);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Item Number  : ${item["2nd Item Number"]}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                          'JDE Quantity : ${item["Total Prim Qty on Hand"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Total Qty          : ${item["Total Quantity"]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: quantityControllers[originalIndex],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Enter physical Qty',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send,
                                  color: Colors.blue),
                              onPressed: () => submitQuantity(index, originalIndex),
                            ),
                          ],
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

  @override
  void dispose() {
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    filterController.dispose();
    super.dispose();
  }
}
