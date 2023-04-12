import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:regexed_validator/regexed_validator.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Expanded(
        flex: 4,
        child: _buildQrView(context),
      ),
      Visibility(
          visible: result != null ? true : false,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                child: Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('Decoded: ',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          const SizedBox(
                            width: 180,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                result = null;
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: result != null
                                  ? ListView(children: [
                                      Text(
                                        "${result!.code}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ])
                                  : const Text(
                                      "No data",
                                    ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: result != null &&
                            validator.url(result!.code.toString()),
                        child: TextButton(
                            onPressed: () {
                              _launchURL(result!.code.toString());
                              setState(() {
                                result = null;
                              });
                            },
                            child: const Text(
                              'Open in browser',
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                onLongPress: () async {
                  await Clipboard.setData(
                      ClipboardData(text: "${result!.code}"));
                },
              ),
            ],
          )))
    ]));
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 500.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _launchURL(String url) async {
    Uri uriUrl = Uri.parse(url);
    if (await canLaunchUrl(uriUrl)) {
      await launchUrl(uriUrl);
    } else {
      throw "Could not launch $uriUrl";
    }
  }
}
