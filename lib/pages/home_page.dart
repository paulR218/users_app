import 'dart:async';

import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/pages/search_destination_page.dart';

import '../methods/common_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';

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


  getCurrentLiveLocationOfUser() async {
    Position  positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng LatLngUserPosition = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: LatLngUserPosition, zoom: 15);

    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.convertGeographicCoordinatesIntoHumanReadableAddress(currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();
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

  Widget build(BuildContext context) {
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
                sKey.currentState!.openDrawer();
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
                child: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  radius: 20,
                  child: Icon(
                    Icons.menu,
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

                    ElevatedButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchDestinationPage()));
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
              ))
        ],
      ),
    );
  }
}
