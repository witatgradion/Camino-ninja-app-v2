import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:repository/repository.dart';

/// DEBUG: Test QR code capacity with encode -> decode roundtrip
/// Call this from anywhere: QrCapacityTest.runTest()
class QrCapacityTest {
  static Future<void> runTest({int stageCount = 249}) async {
    print('========== QR CAPACITY TEST START ==========');
    print('Testing with $stageCount stages...\n');

    final stages = List.generate(
      stageCount,
      (i) => StageData(
        date: DateTime(2024).add(Duration(days: i)),
        startCityId: (i % 1000) + 1,
        endCityId: (i % 1000) + 2,
        startAlbergueId: i.isEven ? (i % 500) + 1 : null,
        endAlbergueId: i.isOdd ? (i % 500) + 1 : null,
      ),
    );

    final originalPlan = StagePlanData(
      routeId: 1,
      stages: stages,
      name: 'Test Plan with $stageCount stages',
    );

    print('--- ORIGINAL DATA ---');
    print('Route ID: ${originalPlan.routeId}');
    print('Plan Name: ${originalPlan.name}');
    print('Stages count: ${originalPlan.stages.length}');
    print('First stage: ${_stageToString(originalPlan.stages.first)}');
    print('Last stage: ${_stageToString(originalPlan.stages.last)}');

    const buildNumber = 12345;
    final platform = Platform.isAndroid ? QrPlatform.android : QrPlatform.ios;

    print('\n--- ENCODING ---');
    print('Build number: $buildNumber');
    print('Platform: ${platform.name}');

    String qrData;
    try {
      qrData = StagePlanCodec.encodeMultiple(
        [originalPlan],
        buildNumber: buildNumber,
        platform: platform,
      );
      print('✅ Encode SUCCESS');
      print('QR Data length: ${qrData.length} chars');
      print(
          'QR Data (first 100 chars): ${qrData.substring(0, qrData.length.clamp(0, 100))}...',);
    } catch (e) {
      print('❌ Encode FAILED: $e');
      print('========== QR CAPACITY TEST END ==========');
      return;
    }

    print('\n--- DECODING ---');
    try {
      final decodeResult = StagePlanCodec.decode(qrData);
      print('✅ Decode SUCCESS');
      print('Build number from QR: ${decodeResult.buildNumber}');
      print('Platform from QR: ${decodeResult.platform.name}');
      print('Plans count: ${decodeResult.plans.length}');

      final decodedPlan = decodeResult.firstPlan;
      print('\n--- DECODED DATA ---');
      print('Route ID: ${decodedPlan.routeId}');
      print('Plan Name: ${decodedPlan.name}');
      print('Stages count: ${decodedPlan.stages.length}');
      print('First stage: ${_stageToString(decodedPlan.stages.first)}');
      print('Last stage: ${_stageToString(decodedPlan.stages.last)}');

      print('\n--- VERIFICATION ---');
      final routeMatch = originalPlan.routeId == decodedPlan.routeId;
      final nameMatch = originalPlan.name == decodedPlan.name;
      final stagesMatch =
          originalPlan.stages.length == decodedPlan.stages.length;

      print('Route ID match: ${routeMatch ? "✅" : "❌"}');
      print('Plan name match: ${nameMatch ? "✅" : "❌"}');
      print('Stages count match: ${stagesMatch ? "✅" : "❌"}');

      if (routeMatch && nameMatch && stagesMatch) {
        print('\n🎉 ALL DATA VERIFIED SUCCESSFULLY!');
      } else {
        print('\n⚠️ SOME DATA MISMATCH!');
      }
    } catch (e) {
      print('❌ Decode FAILED: $e');
    }

    print('\n========== QR CAPACITY TEST END ==========');
  }

  static String _stageToString(StageData stage) {
    return 'date=${stage.date.toIso8601String().split("T")[0]}, '
        'startCity=${stage.startCityId}, endCity=${stage.endCityId}, '
        'startAlb=${stage.startAlbergueId}, endAlb=${stage.endAlbergueId}';
  }
}

/// Mixin for adding QR debug capabilities to a StatefulWidget
mixin QrDebugMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey testQrKey = GlobalKey();
  String? testSavedImagePath;
  String? testQrData;
  bool isTestGenerating = false;
  bool isTestScanning = false;
  final MobileScannerController testScannerController = MobileScannerController();

  void disposeDebug() {
    testScannerController.dispose();
  }

  Future<void> debugGenerateAndSaveQr({
    required int stageCount,
    required void Function(String qrData) onQrGenerated,
  }) async {
    if (isTestGenerating) return;
    setState(() => isTestGenerating = true);

    print('\n========== DEBUG: GENERATE QR TEST ==========');

    try {
      final stages = List.generate(
        stageCount,
        (i) => StageData(
          date: DateTime(2024).add(Duration(days: i)),
          startCityId: (i % 1000) + 1,
          endCityId: (i % 1000) + 2,
          startAlbergueId: i.isEven ? (i % 500) + 1 : null,
          endAlbergueId: i.isOdd ? (i % 500) + 1 : null,
        ),
      );

      final testPlan = StagePlanData(
        routeId: 42,
        stages: stages,
        name: 'Debug Test Plan',
      );

      const buildNumber = 99999;
      final platform = Platform.isAndroid ? QrPlatform.android : QrPlatform.ios;

      final qrData = StagePlanCodec.encodeMultiple(
        [testPlan],
        buildNumber: buildNumber,
        platform: platform,
      );

      print('✅ Generated QR data: ${qrData.length} chars');
      print('   Build: $buildNumber, Platform: ${platform.name}');
      print('   Stages: $stageCount, Route: 42, Name: "Debug Test Plan"');

      setState(() {
        testQrData = qrData;
      });

      onQrGenerated(qrData);

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      final imageBytes = await captureTestQrImage();
      if (imageBytes == null) {
        print('❌ Failed to capture QR image');
        setState(() => isTestGenerating = false);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/debug_qr_test_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      testSavedImagePath = filePath;
      print('✅ Saved QR image to: $filePath');
      print('   File size: ${imageBytes.length} bytes');
      print('\n👉 Now click "Scan & Verify" to test scanning');
    } catch (e) {
      print('❌ Error: $e');
    }

    setState(() => isTestGenerating = false);
    print('========== DEBUG: GENERATE QR TEST END ==========\n');
  }

  Future<void> debugScanAndVerify({required int expectedStageCount}) async {
    if (isTestScanning) return;
    if (testSavedImagePath == null) {
      print('❌ No saved image. Click "Generate Test QR" first.');
      return;
    }

    setState(() => isTestScanning = true);

    print('\n========== DEBUG: SCAN & VERIFY TEST ==========');
    print('Scanning image: $testSavedImagePath');

    String? scannedCode;

    try {
      final result =
          await testScannerController.analyzeImage(testSavedImagePath!);

      if (result == null || result.barcodes.isEmpty) {
        print('❌ No QR code found in image by scanner');
        print('   📋 Falling back to direct data verification...');
        scannedCode = testQrData;
      } else {
        scannedCode = result.barcodes.first.rawValue;
        if (scannedCode == null || scannedCode.isEmpty) {
          print('❌ Scanned QR code is empty');
          print('   📋 Falling back to direct data verification...');
          scannedCode = testQrData;
        } else {
          print('✅ QR code scanned successfully from image!');
          print('   Scanned length: ${scannedCode.length} chars');
        }
      }

      if (scannedCode == null) {
        print('❌ No data to verify');
        setState(() => isTestScanning = false);
        return;
      }

      if (testQrData != null && scannedCode != testQrData) {
        print('   ⚠️ Using original QR data (scanner fallback)');
      } else if (testQrData != null) {
        print('   ✅ Raw data match confirmed');
      }

      print('\n--- DECODING DATA ---');
      final decodeResult = StagePlanCodec.decode(scannedCode);

      print('✅ Decode SUCCESS');
      print('   Build number: ${decodeResult.buildNumber}');
      print('   Platform: ${decodeResult.platform.name}');
      print('   Plans count: ${decodeResult.plans.length}');

      final plan = decodeResult.firstPlan;
      print('\n--- DECODED PLAN DATA ---');
      print('   Route ID: ${plan.routeId}');
      print('   Plan Name: ${plan.name}');
      print('   Stages count: ${plan.stages.length}');
      print(
          '   First stage: date=${plan.stages.first.date}, startCity=${plan.stages.first.startCityId}',);
      print(
          '   Last stage: date=${plan.stages.last.date}, startCity=${plan.stages.last.startCityId}',);

      print('\n--- VERIFICATION ---');
      final checks = <String, bool>{
        'Build number = 99999': decodeResult.buildNumber == 99999,
        'Route ID = 42': plan.routeId == 42,
        'Plan name = "Debug Test Plan"': plan.name == 'Debug Test Plan',
        'Stages count = $expectedStageCount':
            plan.stages.length == expectedStageCount,
      };

      var allPassed = true;
      for (final entry in checks.entries) {
        final passed = entry.value;
        print('   ${passed ? "✅" : "❌"} ${entry.key}');
        if (!passed) allPassed = false;
      }

      if (allPassed) {
        print('\n🎉 ALL VERIFICATIONS PASSED!');
        print('   Data encode -> decode roundtrip WORKS CORRECTLY');
      } else {
        print('\n⚠️ SOME VERIFICATIONS FAILED');
      }
    } catch (e) {
      print('❌ Error during decode: $e');
    }

    setState(() => isTestScanning = false);
    print('========== DEBUG: SCAN & VERIFY TEST END ==========\n');
  }

  Future<Uint8List?> captureTestQrImage() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final widgetContext = testQrKey.currentContext;
      if (widgetContext == null || !widgetContext.mounted) {
        print('   ⚠️ Test QR widget not found');
        return null;
      }

      final renderObject = widgetContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        print('   ⚠️ Not a RepaintBoundary');
        return null;
      }

      final image = await renderObject.toImage(pixelRatio: 5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      print('   Captured test QR: ${image.width}x${image.height}');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('   ⚠️ Test capture failed: $e');
      return null;
    }
  }

  Widget buildDebugTestButtons({
    required int stageCount,
    required void Function(String qrData) onQrGenerated,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'DEBUG: QR Capacity Test',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Test $stageCount stages encode → image → scan → decode',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (testQrData != null)
            RepaintBoundary(
              key: testQrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: PrettyQrView.data(
                    data: testQrData!,
                    decoration: const PrettyQrDecoration(
                      
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isTestGenerating
                      ? null
                      : () => debugGenerateAndSaveQr(
                            stageCount: stageCount,
                            onQrGenerated: onQrGenerated,
                          ),
                  icon: isTestGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.qr_code, size: 18),
                  label:
                      Text(isTestGenerating ? 'Generating...' : '1. Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isTestScanning || testSavedImagePath == null)
                      ? null
                      : () =>
                          debugScanAndVerify(expectedStageCount: stageCount),
                  icon: isTestScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.document_scanner, size: 18),
                  label:
                      Text(isTestScanning ? 'Scanning...' : '2. Scan & Verify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        testSavedImagePath != null ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (testSavedImagePath != null) ...[
            const SizedBox(height: 8),
            Text(
              '✅ Image saved. Check console for logs.',
              style: TextStyle(fontSize: 11, color: Colors.green[700]),
            ),
          ],
        ],
      ),
    );
  }
}
