import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static bool get isLocationSupported => 
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<bool> hasPermission() async {
    if (!isLocationSupported) return false;
    
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> requestPermission() async {
    if (!isLocationSupported) return false;
    
    // Sprawdź czy usługi lokalizacji są włączone
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Sprawdź uprawnienia
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      if (!isLocationSupported) return null;
      
      bool hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Błąd pobierania lokalizacji: $e');
      return null;
    }
  }

  static Future<Map<String, double>> getLocationCoordinates() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    }
    return {
      'latitude': 0.0,
      'longitude': 0.0,
    };
  }
}