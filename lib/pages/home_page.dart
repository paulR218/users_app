import 'dart:async';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/manage_drivers_methods.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/online_nearby_drivers.dart';
import 'package:users_app/pages/search_destination_page.dart';
import 'package:users_app/widgets/info-dialog_box.dart';

import '../appInfo/app_info.dart';
import '../global/trip_var.dart';
import '../methods/common_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';
import '../widgets/loading_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override

  final Completer<GoogleMapController> googleMapCompleterController =  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchHeightContainer = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;

  makeDriverNearbyCarIcon(){
    if(carIconNearbyDriver == null){
      ImageConfiguration configuration = createLocalImageConfiguration(context, size: Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(configuration, "assets/images/tracking.png").then((iconImage)
      {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  getCurrentLiveLocationOfUser() async {
    Position  positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng LatLngUserPosition = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: LatLngUserPosition, zoom: 15);

    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.convertGeographicCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
         .child(FirebaseAuth.instance.currentUser!.uid);
    await usersRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        if((snap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
          cMethods.displaySnackbar("Your account is blocked. Contact admin", context);
        }
      } else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });

  }

  displayUserRideDetailsContainer() async {
    //draw route between pickup and dropoff
    await retrieveDirectionDetails();
    setState(() {
      searchHeightContainer = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 242;
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails() async {
    var pickupLocation = Provider.of<AppInfo>(context,listen: false).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(context,listen: false).dropOffLocation;
    var pickupGeoGraphicCoordinates = LatLng(pickupLocation!.latitudePosition!, pickupLocation.longitudePosition!);
    var dropOffDestinationGeoGraphicCoordinates = LatLng(dropOffDestinationLocation!.latitudePosition!, dropOffDestinationLocation.longitudePosition!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)  => LoadingDialog(messageText: "Getting Direction"),
    );

    ///Directions API
    var detailsFromDirectionAPI = await CommonMethods.getDirectionDetailsFromAPI(pickupGeoGraphicCoordinates, dropOffDestinationGeoGraphicCoordinates);

    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);


    ///draw route from pickup to destination
    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination = pointsPolyline.decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);


    polyLineCoordinates.clear();
    if(latLngPointsFromPickUpToDestination.isNotEmpty){
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) {
        polyLineCoordinates.add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("polylineID"),
        color: Colors.pink,
        points: polyLineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    //fit polyline into the map
    LatLngBounds boundsLatlng;
    if(pickupGeoGraphicCoordinates.latitude > dropOffDestinationGeoGraphicCoordinates.latitude &&
        pickupGeoGraphicCoordinates.longitude > dropOffDestinationGeoGraphicCoordinates.longitude){
      boundsLatlng = LatLngBounds(southwest: dropOffDestinationGeoGraphicCoordinates, northeast: pickupGeoGraphicCoordinates);
    }
    else if(pickupGeoGraphicCoordinates.longitude > dropOffDestinationGeoGraphicCoordinates.longitude){
      boundsLatlng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoordinates.latitude, dropOffDestinationGeoGraphicCoordinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoordinates.latitude, pickupGeoGraphicCoordinates.longitude),
      );
    }
    else if(pickupGeoGraphicCoordinates.latitude > dropOffDestinationGeoGraphicCoordinates.latitude){
      boundsLatlng = LatLngBounds(
          southwest: LatLng(dropOffDestinationGeoGraphicCoordinates.latitude, pickupGeoGraphicCoordinates.longitude),
          northeast: LatLng(pickupGeoGraphicCoordinates.latitude,dropOffDestinationGeoGraphicCoordinates.longitude),
      );
    }
    else{
      boundsLatlng = LatLngBounds(southwest: pickupGeoGraphicCoordinates, northeast: dropOffDestinationGeoGraphicCoordinates);
    }

    controllerGoogleMap!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatlng, 72));

    //add the markers from pickup and destination
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickupLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffPointMarker = Marker(
      markerId: const MarkerId("dropOffPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: dropOffDestinationLocation.placeName, snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffPointMarker);
    });

    //add the circles from pickup and destination
    Circle pickUpPointCircle = Circle(
      circleId: const CircleId("pickupCircleID"),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoordinates,
      fillColor: Colors.pink
    );

    Circle dropOffDestinationPointCircle = Circle(
        circleId: const CircleId("dropOffDestinationCircleID"),
        strokeColor: Colors.blue,
        strokeWidth: 4,
        radius: 14,
        center: dropOffDestinationGeoGraphicCoordinates,
        fillColor: Colors.green
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
    /// end of drawing route from pickup to destination
  }

  resetAppNow(){
    setState(() {
      polyLineCoordinates.clear();
      polyLineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchHeightContainer = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDriver = "Driver is Arriving";
    });
  }

  cancelRideRequest(){
    //remove ride request from database
    tripRequestRef!.remove();
    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer(){
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    //send ride request
    makeTripRequest();
  }

  updateAvailableOnlineDriversOnMap(){

    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = Set<Marker>();

    for(OnlineNearbyDrivers eachOnlineNearbyDriver in ManageDriversMethod.nearbyOnlineDriversList){
      LatLng driverCurrentPosition = LatLng(eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
          markerId: MarkerId("driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }
    setState(() {
      markerSet = markersTempSet;
    });
  }

  initializeGeoFireListener(){
    Geofire.initialize("onlineDrivers");
    Geofire.queryAtLocation(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude, 5)!.listen((driverEvent)
    {
      if(driverEvent != null){
        var onlineDriverChild = driverEvent["callback"];

        switch(onlineDriverChild){
          case Geofire.onKeyEntered:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = driverEvent["latitude"];
            onlineNearbyDrivers.lngDriver = driverEvent["longitude"];
            ManageDriversMethod.nearbyOnlineDriversList.add(onlineNearbyDrivers);

            if(nearbyOnlineDriversKeysLoaded == true){
              //update drivers on google map
              updateAvailableOnlineDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            ManageDriversMethod.removeDriverFromList(driverEvent["key"]);

            updateAvailableOnlineDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            updateAvailableOnlineDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;
            updateAvailableOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  makeTripRequest(){
    tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").push();

    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    Map pickUpCoordinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoordinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoordinates = {
       "latitude":"",
      "longitude":"",
    };

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime" : DateTime.now().toString(),
      "userName" : userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickupLatLng": pickUpCoordinatesMap,
      "dropOffLatLng": dropOffDestinationCoordinatesMap,
      "pickupAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,

      "driverID":"waiting",
      "carDetails" : "",
      "driverLocation": driverCoordinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "deliveryAmount": "",
      "status": "new",
    };

    tripRequestRef!.set(dataMap);
  }

  noDriverAvailable(){
    showDialog(
        context: context,
        barrierDismissible: false ,
        builder: (BuildContext context) => InfoDialog(
          title: "No Driver Available",
          description: "No driver found in the nearby location. Please try again shortly.",
        ));
  }

  searchDriver(){
    if(availableNearbyOnlineDriversList!.length == 0){
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    var currentDriver = availableNearbyOnlineDriversList![0];

    //send notification to the current driver

    availableNearbyOnlineDriversList!.removeAt(0);

  }

  Widget build(BuildContext context) {

    makeDriverNearbyCarIcon();

    return Scaffold(
      key:sKey,
      drawer: Container(
        width: 230,
        color: Colors.amber,
        child: Drawer(
          backgroundColor: Colors.white10,
            child: ListView(
              children: [

              //header
              Container(
                  color: Colors.amber,
                  height: 160,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/avatarman.png",
                          width: 60,
                          height: 60,
                        ),

                        const SizedBox(width : 16,),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo
                              ),
                            ),
                            const Text(
                              "Profile",
                              style: TextStyle(
                                color: Colors.indigo,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
            ),

              const Divider(
                height: 1,
                color: Colors.indigo,
                thickness: 1,
              ),

              const SizedBox(height: 10,),

              //body
              ListTile(
                leading: IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.info, color: Colors.indigo,)
                ),
                title: const Text("About", style: TextStyle(color: Colors.indigo),),
              ),

              GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                      onPressed: (){
                        FirebaseAuth.instance.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                      },
                      icon: const Icon(Icons.logout, color: Colors.indigo,)
                  ),
                  title: const Text("Logout", style: TextStyle(color: Colors.indigo),),
                
                ),
              ),
              ],
            ),
       ),
      ),
      body: Stack(
        children: [
          ///google map
          GoogleMap(
            padding:  EdgeInsets.only(top: 25, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController){
              controllerGoogleMap = mapController;

              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 140;
              });

              getCurrentLiveLocationOfUser();


            },
          ),

          ///drawer button or menu button
          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                if(isDrawerOpened == true) {
                  sKey.currentState!.openDrawer();
                }
                else{
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const
                  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.amber,
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true ? Icons.menu : Icons.close,
                    color: Colors.indigo,
                  ),
                ),
              ),

            ),
          ),

          ///search location icon button
          Positioned(
              left: 0,
              right: 0,
              bottom: -80,
              child:  Container(
                height: searchHeightContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    ElevatedButton(onPressed: () async {
                      var responseFromSearchPage = await Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchDestinationPage()));

                      if(responseFromSearchPage == "placeSelected"){
                          displayUserRideDetailsContainer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),

                      ),
                     child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 25,
                     ),
                    ),

                    ElevatedButton(onPressed: (){

                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),

                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),

                    ElevatedButton(onPressed: (){

                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),

                      ),
                      child: const Icon(
                        Icons.work,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),

                  ],
                ),
              )),

          ///ride details container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white12,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 16, right: 16),
                    child: SizedBox(
                      height: 195,
                      child: Card(
                        elevation: 10,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.70,
                          color: Colors.black45,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (tripDirectionDetailsInfo != null) ? tripDirectionDetailsInfo!.distanceTextString! :"0 km",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        (tripDirectionDetailsInfo != null) ? tripDirectionDetailsInfo!.durationTextString! :"0 sec",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),


                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      stateOfApp = "requesting";
                                    });

                                    displayRequestContainer();

                                    //get nearest available online driver
                                    availableNearbyOnlineDriversList = ManageDriversMethod.nearbyOnlineDriversList;

                                    //search driver
                                    searchDriver();
                                  },
                                  child: Image.asset(
                                      "assets/images/uberexec.png",
                                    height: 122,
                                    width: 122,
                                  ),
                                ),

                                //estimated fare amount
                                const Text(
                                  "\$ 12",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),)
                  ],
                ),
              ),
            ),
          ),
          ///end ride details container
          
          ///request container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: requestContainerHeight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7,0.7)
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12,),

                    SizedBox(
                      width: 200,
                      child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.greenAccent,
                          rightDotColor: Colors.pinkAccent,
                          size: 50),
                    ),

                    const SizedBox(height: 20,),

                    GestureDetector(
                      onTap: (){
                        resetAppNow();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1.5, color: Colors.grey),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
          ///end request container
        ],
      ),
    );
  }
}
