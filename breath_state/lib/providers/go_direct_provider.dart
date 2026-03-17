import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:breath_state/services/go_direct/go_direct_service.dart';
import 'package:breath_state/services/go_direct/go_direct_constants.dart';

class GoDirectProvider extends ChangeNotifier {
  final GoDirectService _service = GoDirectService();

  StreamSubscription<List<GoDirectScannedDevice>>? _scanSub;

  GoDirectProvider() {
    _service.connectionState.addListener(_onStateChanged);

    _scanSub = _service.scanResults.listen((devices) {
      lastScanResults = devices;
      notifyListeners();
    });
  }

  GoDirectConnectionState get connectionState =>
      _service.connectionState.value;

  bool get isConnected => _service.isConnected;
  bool get isStreaming => _service.isStreaming;
  String? get connectedDeviceName => _service.connectedDeviceName;
  List<GoDirectSensorInfo> get availableSensors => _service.availableSensors;

  Stream<List<GoDirectScannedDevice>> get scanResults =>
      _service.scanResults;

  Stream<GoDirectMeasurement> get measurementStream =>
      _service.measurementStream;

  Stream<double> get respirationForceStream =>
      _service.respirationForceStream;


  List<GoDirectScannedDevice> lastScanResults = [];

  Future<void> startScan() async {
    await _service.startScan();
    notifyListeners();
  }

  Future<void> stopScan() async {
    await _service.stopScan();
    notifyListeners();
  }

  Future<bool> connect(String deviceId) async {
    notifyListeners();
    final success = await _service.connect(deviceId);
    notifyListeners();
    return success;
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    notifyListeners();
  }

  Future<void> startMeasurements({
    List<int>? sensorNumbers,
    int periodMs = 100,
  }) async {
    await _service.startMeasurements(
      sensorNumbers: sensorNumbers,
      periodMs: periodMs,
    );
    notifyListeners();
  }

  Future<void> stopMeasurements() async {
    await _service.stopMeasurements();
    notifyListeners();
  }

  void _onStateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _service.connectionState.removeListener(_onStateChanged);
    _scanSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
