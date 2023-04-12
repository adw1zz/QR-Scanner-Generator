import 'package:flutter/material.dart';
import 'package:qr_scanner_generator/pages/home.dart';
import 'package:qr_scanner_generator/pages/qr_generator.dart';
import 'package:qr_scanner_generator/pages/qr_scanner.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeScreen(),
      '/generator': (context) => const QRGeneratorScreen(),
      '/scanner': (context) => const QRScannerScreen(),
    },
  ));
}
