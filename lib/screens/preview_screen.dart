import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PreviewScreen extends StatefulWidget {
  final bool isStatic;
  final bool useTemplate;

  const PreviewScreen({
    Key? key, 
    required this.isStatic, 
    this.useTemplate = false
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String qrData = 'https://example.com';
  Color qrColor = Colors.black;
  Color backgroundColor = Colors.white;
  String? selectedTemplate;
  String? selectedFrame;
  final TextEditingController _textController = TextEditingController(text: 'https://example.com');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.useTemplate ? 'Custom Template QR' : (widget.isStatic ? 'Static QR Code' : 'Dynamic QR Code')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Code saved!')),
              );
              // TODO: Implement actual save functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // QR Code Preview
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (selectedTemplate != null)
                        Image.asset(
                          'assets/backgrounds/$selectedTemplate',
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: backgroundColor,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: qrColor,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: qrColor,
                        ),
                      ),
                      if (selectedFrame != null)
                        Image.asset(
                          'assets/frames/$selectedFrame',
                          width: 240,
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Template Options (shown only when useTemplate is true)
            if (widget.useTemplate) ...[
              const Text(
                'Background Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTemplateOption(null, 'None'),
                    _buildTemplateOption('geometric-pattern.png', 'Geometric'),
                    _buildTemplateOption('abstract-pattern.png', 'Abstract'),
                    _buildTemplateOption('modern-pattern.png', 'Modern'),
                    _buildTemplateOption('vintage-pattern.png', 'Vintage'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Decorative Frame',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFrameOption(null, 'None'),
                    _buildFrameOption('flower-frame.png', 'Flower'),
                    _buildFrameOption('star-frame.png', 'Star'),
                    _buildFrameOption('heart-frame.png', 'Heart'),
                    _buildFrameOption('sun-frame.png', 'Sun'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Content Input
            const Text(
              'QR Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter URL or text',
              ),
              onChanged: (value) {
                setState(() {
                  qrData = value;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Color Selection
            const Text(
              'QR Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showColorPicker(
                      context, 
                      qrColor, 
                      (color) => setState(() => qrColor = color)
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: qrColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Tap to change QR color'),
              ],
            ),
            const SizedBox(height: 20),
            
            // Background Color Selection
            const Text(
              'Background Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showColorPicker(
                      context, 
                      backgroundColor, 
                      (color) => setState(() => backgroundColor = color)
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Tap to change background color'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String? templateName, String label) {
    final bool isSelected = selectedTemplate == templateName;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTemplate = templateName;
          });
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: templateName == null
                  ? const Center(child: Icon(Icons.block))
                  : Image.asset(
                      'assets/backgrounds/$templateName',
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameOption(String? frameName, String label) {
    final bool isSelected = selectedFrame == frameName;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedFrame = frameName;
          });
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: frameName == null
                  ? const Center(child: Icon(Icons.block))
                  : Image.asset(
                      'assets/frames/$frameName',
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}