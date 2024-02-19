import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/prediction_place_pickup.dart';

import '../appInfo/app_info.dart';


class SearchPickupPage extends StatefulWidget {
  const SearchPickupPage({super.key});

  @override
  State<SearchPickupPage> createState() => _SearchPickupPageState();
}

class _SearchPickupPageState extends State<SearchPickupPage> {

  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<PredictionModel> pickUpPredictionsPlacesList = [];


  ///Google Places API - Place autocomplete
  searchLocation(String locationName) async {
    if(locationName.length > 1){
      String apiPlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:ph";

      var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(apiPlacesUrl);

      if(responseFromPlacesAPI == "error"){
        return;
      }
      if(responseFromPlacesAPI["status"] == "OK"){
        var predictionResultInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionResultInJson as List).map((eachPlacePrediction) => PredictionModel.fromJson(eachPlacePrediction)).toList();
        setState(() {
          pickUpPredictionsPlacesList = predictionsList;
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String destinationAddress = "Mega Pacific Freight Logistics, Inc.";
    destinationTextEditingController.text = destinationAddress;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 230,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6,),

                      //title and icon button
                      Stack(
                        children: [
                          GestureDetector(onTap: ()
                          {
                            Navigator.pop(context);
                          },
                              child: const Icon(Icons.arrow_back, color: Colors.white,)
                          ),

                          const Center(
                            child: Text(
                              "Set Pick-Up Location",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18,),
                      //pickup text field
                      Row(
                        children: [
                          Image.asset("assets/images/initial.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18,),

                          Expanded(child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: TextField(
                                controller: pickupTextEditingController,
                                onChanged: (inputText){
                                  searchLocation(inputText);
                                },
                                decoration: const InputDecoration(
                                    hintText: "Pickup address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense:true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11,),
                      //destination
                      Row(
                        children: [
                          Image.asset("assets/images/final.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18,),

                          Expanded(child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: TextField(
                                controller: destinationTextEditingController,

                                decoration: const InputDecoration(
                                    hintText: "Destination address",
                                    fillColor: Colors.white12,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense:true,
                                    contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //display prediction results for destinations place
            (pickUpPredictionsPlacesList.isNotEmpty)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index)
                {
                  return Card(
                    elevation: 3,
                    child: PredictionPlacePickUp(
                      predictedPlaceData: pickUpPredictionsPlacesList[index],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 2,),
                itemCount: pickUpPredictionsPlacesList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                :Container(),
            /*ElevatedButton(onPressed: onPressed, child: child)*/
          ],
        ),
      ),
    );
  }
}
