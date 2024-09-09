import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bildauswahl Beispiel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _imageFile;
  String _outputFormat = 'PDF';
  double _blurRadius = 0;
  int _x = 0;
  int _y = 0;
  int _width = 0;
  int _height = 0;

  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _blurImage() async {
    if (_imageFile == null || _blurRadius <= 0 || _width <= 0 || _height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ungültiges Bild oder unscharfe Parameter.')),
      );
      return;
    }

    final imageBytes = await _imageFile!.readAsBytes();
    img.Image originalImage = img.decodeImage(imageBytes)!;

    if (_x < 0 || _y < 0 || _x + _width > originalImage.width || _y + _height > originalImage.height) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ungültige Zuschneide-Dimensionen.')),
      );
      return;
    }

    img.Image section = img.copyCrop(originalImage, x: _x, y: _y, width: _width, height: _height);
    img.Image blurredSection = img.gaussianBlur(section, radius: _blurRadius.toInt());

    for (int y = 0; y < blurredSection.height; y++) {
      for (int x = 0; x < blurredSection.width; x++) {
        originalImage.setPixel(_x + x, _y + y, blurredSection.getPixel(x, y));
      }
    }

    if (_outputFormat == 'Image') {
      await _saveImage(originalImage);
    } else {
      await _createPDF(originalImage);
    }
  }

  Future<void> _saveImage(img.Image originalImage) async {
    // Implementiere deine Funktion zum Speichern des Bildes hier
  }

  Future<void> _createPDF(img.Image originalImage) async {
    // Implementiere deine Funktion zum Erstellen von PDFs hier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bild laden und unscharf machen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? Text('Kein Bild ausgewählt.')
                : Image.file(_imageFile!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Bild aus Galerie auswählen'),
            ),
            DropdownButton<String>(
              value: _outputFormat,
              onChanged: (String? newValue) {
                setState(() {
                  _outputFormat = newValue!;
                });
              },
              items: <String>['Image', 'PDF']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Slider(
              value: _blurRadius,
              min: 0,
              max: 100,
              divisions: 100,
              label: 'Unschärferadius: ${_blurRadius.toInt()}',
              onChanged: (double value) {
                setState(() {
                  _blurRadius = value;
                });
              },
            ),
            TextField(
              controller: _xController,
              decoration: InputDecoration(labelText: 'X-Koordinate'),
              onChanged: (String value) {
                setState(() {
                  _x = int.tryParse(value) ?? 0;
                });
              },
            ),
            TextField(
              controller: _yController,
              decoration: InputDecoration(labelText: 'Y-Koordinate'),
              onChanged: (String value) {
                setState(() {
                  _y = int.tryParse(value) ?? 0;
                });
              },
            ),
            TextField(
              controller: _widthController,
              decoration: InputDecoration(labelText: 'Breite'),
              onChanged: (String value) {
                setState(() {
                  _width = int.tryParse(value) ?? 0;
                });
              },
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Höhe'),
              onChanged: (String value) {
                setState(() {
                  _height = int.tryParse(value) ?? 0;
                });
              },
            ),
            ElevatedButton(
              onPressed: _blurImage,
              child: Text('Unschärfe anwenden und speichern'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
