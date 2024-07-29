import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../generated/l10n.dart';
import '../../service/app_drawer.dart';

class ScanItemQr extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const ScanItemQr(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  _ScanItemQrState createState() => _ScanItemQrState();
}

class _ScanItemQrState extends State<ScanItemQr> {
  // final MobileScannerController _cameraController = MobileScannerController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Ensure the camera is initialized (if needed)
    //  await _cameraController.start();
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('sound/beep.mp3'));
  }

  void _handleScan(String code) {
    // Display snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قراءة الكود بنجاح: $code'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Play alert sound
    _playSound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S().scan} ${S().new1} ${S().item}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      /*    body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            
            ElevatedButton(
              onPressed: scanWithCamera,
              child: Text('Scan QR Code / PDF417'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload Image/PDF'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: scannedCodes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                   // title: Text(scannedCodes[index]),
                  );
                },
              ),
            ),
            
          ],
        ),
      ),
   */

      body: Container(),

      /*
      MobileScanner(
        controller: _cameraController,
        onDetect: (barcode, args) {
          final String code = barcode.rawValue ?? 'Unknown';
          _handleScan(code);
        },
      ),
      */
    );
  }
}
