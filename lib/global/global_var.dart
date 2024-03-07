import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userEmail = "";
String userID = FirebaseAuth.instance.currentUser!.uid;
String googleMapKey = "AIzaSyDjkmC-NlWZRmKqYttx8x-e_G29ZNFSLL4";
String serverKeyFCM = "key=AAAAL9Ynsk8:APA91bGwuKKAr6UzCmzn8b7O6__xT4DCq9j8gihhmRku55WVnSO7DFPXUlEtvx7vkGmqo-apsguRfitUdy71BaooBWn0xZH3lInROIqx1Fxf5e3ljq5RSZFA8OuIuJ7J8s6-AcLN0C28";
StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;
Position? driverCurrentPosition;

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(14.60420000, 120.98220000),
  zoom: 14.4746,
);
