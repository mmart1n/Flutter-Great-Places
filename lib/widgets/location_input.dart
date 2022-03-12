import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_places_app/helpers/google_helper.dart';
import 'package:great_places_app/models/place.dart';
import 'package:great_places_app/screens/map_screen.dart';

import '../helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  const LocationInput(this.onSelectPlace, {Key? key}) : super(key: key);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;
  PlaceLocation? _chosenLoc;

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
      if (locData != null) {
        _chosenLoc = PlaceLocation(
            latitude: locData.latitude!, longitude: locData.longitude!);

        _previewImageUrl = GoogleHelper.generateLocationPreviewImage(
          latitude: locData.latitude!,
          longitude: locData.longitude!,
        );

        widget.onSelectPlace(locData.latitude, locData.longitude);
      }
    });
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _chosenLoc != null
            ? MapScreen(
                isSelecting: true,
                initialLocation: _chosenLoc!,
              )
            : const MapScreen(
                isSelecting: true,
              ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }

    setState(() {
      _chosenLoc = PlaceLocation(
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude);

      _previewImageUrl = GoogleHelper.generateLocationPreviewImage(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );
    });

    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
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
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
