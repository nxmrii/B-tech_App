import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng initialLocation;

  MapScreen({
    required this.onLocationSelected,
    this.initialLocation = const LatLng(23.5880, 58.3829), // Muscat, Oman
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected Location: ${location.latitude}, ${location.longitude}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1B93C5),
        title: Text('Select Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
               widget.onLocationSelected(_selectedLocation!);
              },
            )
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 10,
        ),
        onTap: _onMapTap,
        markers: {
          if (_selectedLocation != null)
            Marker(
              markerId: MarkerId('selected'),
              position: _selectedLocation!,
            ),
          if (_selectedLocation == null)
            Marker(
              markerId: MarkerId('initial'),
              position: widget.initialLocation,
            ),
        },
      ),
    );
  }
}
