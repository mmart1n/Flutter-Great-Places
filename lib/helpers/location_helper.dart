import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

var locHelper = _LocationHelper();

class _LocationHelper {
  final location = Location();
  PermissionStatus? _permissionStatus;

  Future<LocationData?> getLocation(BuildContext? context) async {
    final isLocEnabled = await _isLocServiceEnabled;
    if (!isLocEnabled) {
      return null;
    }

    final hasPermission = await _isPermissionGranted(context);
    if (!hasPermission) {
      return null;
    }

    return location.getLocation();
  }

  Future<bool> get _isLocServiceEnabled async {
    bool _serviceEnabled;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _isPermissionGranted(BuildContext? context) async {
    _permissionStatus = await location.hasPermission();

    if (_permissionStatus != PermissionStatus.granted) {
      _permissionStatus = await location.requestPermission();
    }

    if (_permissionStatus == PermissionStatus.denied) {
      // req permission dialog opens and user denies permission
      return false;
    }

    if (_permissionStatus == PermissionStatus.deniedForever &&
        context != null) {
      // permission dialog not opened
      final openAppSettings = await _shouldOpenAppSettings(context);
      if (openAppSettings == null || !openAppSettings) {
        return false;
      }
      await AppSettings.openAppSettings();
      return false;
    }

    if (_permissionStatus != PermissionStatus.granted) {
      return false;
    }

    return true;
  }

  Future<bool?> _shouldOpenAppSettings(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'The app need acces to the location of your device in order to proceed'),
        content: const Text(
            'Do you want to visit app settings and enable the location permissions? Allow always will help us with...'),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _isBackgroundLocEnabled(BuildContext context) async {
    final isEnabled = await location.isBackgroundModeEnabled();
    if (!isEnabled) {
      try {
        await location.enableBackgroundMode(enable: true);
      } catch (error) {
        print('permanently denied');
        // handle it
      }
    }
  }
}
