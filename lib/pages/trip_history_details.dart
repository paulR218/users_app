import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/models/trips_history_model.dart';
import 'package:users_app/pages/trip_history_page.dart';
import 'package:users_app/pages/trip_history_photo.dart';

class tripHistoryDetails extends StatefulWidget {
  final String? tripID;
  final String? driverName;
  final String? date;
  final String? driverPhone;
  final String? pickUpAddress;

  final String? pickUpPhoto;
  final String? dropOffPhoto;

  const tripHistoryDetails({super.key, this.tripID, this.date, this.driverName, this.pickUpPhoto, this.dropOffPhoto, this.driverPhone, this.pickUpAddress});

  @override
  State<tripHistoryDetails> createState() => _tripHistoryDetails();
}

class _tripHistoryDetails extends State<tripHistoryDetails> {
  TripHistoryModel tripHistoryModel = TripHistoryModel();



  @override
  Widget build(BuildContext context)  {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 20,
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          "Completed Trip",
          style: TextStyle(
              color: Colors.white
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey,
            height: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    height: 100,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/images/avatarman.png"),
                          ),
                        ),
                        const SizedBox(width: 50,),

                        Text(
                          widget.driverName!,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    height: 400,
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 300 ,
                              width: 50,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/images/initial.png",
                                    height: 30,
                                    width: 30,),

                                  const SizedBox(height: 150,),

                                  Image.asset(
                                    "assets/images/final.png",
                                    height: 30,
                                    width: 30,),
                                ],
                              ),
                            ),
                          ]
                        ),
                        const SizedBox(width: 30,),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 500,
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 40)),
                                Flexible(
                                  child: Text(
                                    widget.date!,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.pickUpAddress!,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.driverName!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5,),
                                    Flexible(
                                      child: Text(
                                        widget.driverPhone!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => tripPhoto(photo: widget.pickUpPhoto,)));
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                       color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                    ),
                                    height: 50,
                                    width: 230,
                                    padding: const EdgeInsets.all(10),
                                    child: const Text(
                                        "Photo proof",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 50,),

                                Flexible(
                                  child: Text(
                                    widget.date!,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey
                                    ),
                                  ),
                                ),
                                const Flexible(
                                  child: Text(
                                    "Mega Pacific Freight Logistics Inc.",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.driverName!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5,),
                                    Flexible(
                                      child: Text(
                                        widget.driverPhone!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => tripPhoto(photo: widget.dropOffPhoto,)));
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                    ),
                                    height: 50,
                                    width: 230,
                                    padding: const EdgeInsets.all(10),
                                    child: const Text(
                                      "Photo proof",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),

              ],
        )

        )
      ),
    );
  }
}






