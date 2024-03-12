import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/models/trips_history_model.dart';
import 'dart:developer';
import 'trip_history_details.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {

  TripHistoryModel tripHistoryModel = TripHistoryModel();
  String? pickUpPhotoUrl;
  String? dropOffPhotoUrl;
  final completedTripRequestsOfCurrentUser =  FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Trips History",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentUser.onValue,
        builder: (BuildContext context, snapshotData){
          if(snapshotData.hasError){
            return const Center(
              child: Text(
                "Error Occurred",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          if(!(snapshotData.hasData)){
            return const Center(
              child: Text(
                "No record found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips.forEach((key, value) => tripsList.add({"key": key, ...value}));
          //log("tripsList \n $tripsList");

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index){
              if(tripsList[index]["status"] != null
                  && tripsList[index]["status"] == "ended"
                  && tripsList[index]["userID"] == FirebaseAuth.instance.currentUser!.uid)
              {
                var tripID =  tripsList[index]["tripID"];
                var driverName = tripsList[index]["driverName"];
                var driverPhone = tripsList[index]["driverPhone"];
                var date = tripsList[index]["publishDateTime"];
                var pickUpAddress = tripsList[index]["pickUpAddress"];
                try{
                  pickUpPhotoUrl = tripsList[index]["pickUpPhoto"]["pickUpPhoto"];
                  dropOffPhotoUrl = tripsList[index]["dropOffPhoto"]["dropOffPhoto"];
                }catch(e){
                  print(e);
                }
                return Card(
                  color: Colors.black,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c) => tripHistoryDetails
                              (tripID: tripID, date: date, driverName: driverName, driverPhone: driverPhone,pickUpAddress: pickUpAddress ,
                              pickUpPhoto: pickUpPhotoUrl,
                              dropOffPhoto: dropOffPhotoUrl,)));
                          },
                          child: Column(
                            children: [
                                Row(
                                children: [
                                Text(
                                tripsList[index]["publishDateTime"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                              const Divider(
                                color: Colors.white,
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Image.asset("assets/images/initial.png", height: 16, width: 16,),

                                  const SizedBox(width: 18,),

                                  Expanded(
                                    child: Text(
                                      tripsList[index]["pickUpAddress"].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8,),

                              Row(
                                children: [
                                  Image.asset("assets/images/final.png", height: 16, width: 16,),

                                  const SizedBox(width: 18,),

                                  Expanded(
                                    child: Text(
                                      tripsList[index]["dropOffAddress"].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                            )
                          ],
                        ),
                        )
                      ],
                    ),
                  ),
                );
              }
              else{
                return Container();
              }
            }
            ),
          );
        }
      ),
    );
  }
}
