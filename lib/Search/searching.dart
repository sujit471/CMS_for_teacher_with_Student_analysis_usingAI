import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String prediction = ''; // Initialize prediction variable
  TextEditingController inputController = TextEditingController();

  Future<void> fetchPrediction(List<int> input) async {
    final response = await http.post(
      Uri.parse('https://flask-for-model-0-0-1-release.onrender.com/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'input_array': input}),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        int predictionCode = data['prediction']; // Remove [0]
        if (predictionCode == 1) {
          prediction = 'Pass in all subjects';
        } else if (predictionCode == 2) {
          prediction = 'Fail in 1';
        } else if (predictionCode == 3) {
          prediction = 'Fail in 2 to 3';
        } else if (predictionCode == 4) {
          prediction = 'Fail in 4 to 5';
        } else if (predictionCode == 5) {
          prediction = 'Fail in all subjects';
        }
      });
    } else {
      throw Exception('Failed to load prediction');
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: inputController,
              decoration: const InputDecoration(
                labelText: 'Enter input values (comma separated)',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                List<int> inputValues = inputController.text.split(',').map((e) => int.parse(e.trim())).toList();
                fetchPrediction(inputValues);
              },
              child: const Text('Get Prediction'),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Prediction: $prediction',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
