

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_image_generator/qr_image_generator.dart';
import 'package:permission_handler/permission_handler.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final informationController = TextEditingController();
  final fileNameController = TextEditingController();
  String fullPath = "";
  bool isGenerated = false;
  bool isDirSelected = false;

  Future selectDir(String fileName) async {
    isGenerated = false;
    if (fileName == '') {
      return;
    }

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    String? fileDirectory = await FilePicker.platform.getDirectoryPath();
    return "$fileDirectory/$fileName.png";
  }

  Future saveQrImage(String data, String path) async {
    if (path == '' || data == '') {
      return;
    }

    final generator = QRGenerator();

    await generator.generate(
      data: data,
      filePath: path,
      scale: 10,
      padding: 2,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      errorCorrectionLevel: ErrorCorrectionLevel.medium,
    );
    isGenerated = true;
  }

  @override
  void dispose() {
    super.dispose();
    informationController.dispose();
    fileNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR code generator',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Data',
              ),
              controller: informationController,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'File Name',
              ),
              controller: fileNameController,
            ),
          ),
        
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(150, 10)),
              onPressed: () async {
                await saveQrImage(
                    informationController.text, fullPath);
                showDialog(context: context, builder: ((context) {
                    return const AlertDialog(content: Text("Generated"));
                }));
              },
              child: const Text("Generate"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(150, 10)),
              onPressed: () async {
                fullPath = await selectDir(
                    fileNameController.text);
              },
              child: const Text("Select Directory"),
            ),
          ]),
        ],
      ),
    ));
  }
}
