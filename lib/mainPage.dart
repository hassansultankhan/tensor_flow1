import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  String _prediction = "";
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/linear_model.tflite');
      print("Model loaded");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<void> predict(double input) async {
    if (_interpreter == null) {
      print("Model not loaded yet.");
      return;
    }

    try {
      var inputBuffer = _convertInputToByteBuffer(input);
      var outputBuffer = List.filled(1, 0.0).reshape([1, 1]);

      _interpreter!.run(inputBuffer, outputBuffer);

      setState(() {
        _prediction = outputBuffer[0][0].toString();
      });
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Uint8List _convertInputToByteBuffer(double input) {
    ByteData byteData = ByteData(4);
    byteData.setFloat32(0, input, Endian.little);
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TensorFlow',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter a number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      backgroundColor: Color.fromARGB(255, 235, 190, 108)),
                  onPressed: () {
                    predict(5.0);
                  },
                  child: const Text(
                    'Predict for 5.0',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Prediction: $_prediction',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
