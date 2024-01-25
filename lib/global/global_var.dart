import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
String googleMapKey = "AIzaSyDjkmC-NlWZRmKqYttx8x-e_G29ZNFSLL4";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(14.60420000, 120.98220000),
  zoom: 14.4746,
);
