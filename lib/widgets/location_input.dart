import 'package:flutter/material.dart';

import '../helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({Key? key}) : super(key: key);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    setState(() {
      showDialog(
        context: context,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
    final locData = await locHelper.getLocation(context);
    setState(() {
      Navigator.of(context).pop();
    });
    if (locData != null) {
      print(locData.latitude);
      print(locData.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? const Text(
                  'No Location Chosen!',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              label: const Text('Current Location'),
              icon: const Icon(Icons.location_on),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: _getCurrentUserLocation,
            ),
            TextButton.icon(
              label: const Text('Select on Map'),
              icon: const Icon(Icons.map),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
