import "package:flutter/material.dart";
// import "package:google_maps_flutter/google_maps_flutter.dart";

class MapsScreen extends StatefulWidget {
  static const String routeName = "/maps-screen";
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // body: GoogleMap(
      //   initialCameraPosition: _kGooglePlex,
      // ),
    );
  }
}
