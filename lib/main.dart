import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TensorFlow Lite with Flutter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  predict(5.0);
                },
                child: Text('Predict for 5.0'),
              ),
              Text(
                'Prediction: $_prediction',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
