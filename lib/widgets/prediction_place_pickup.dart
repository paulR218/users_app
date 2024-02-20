import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class PredictionPlacePickUp extends StatefulWidget {

  PredictionModel? predictedPlaceData;

  PredictionPlacePickUp({super.key, this.predictedPlaceData,});

  @override
  State<PredictionPlacePickUp> createState() => _PredictionPlacePickUpState();
}

class _PredictionPlacePickUpState extends State<PredictionPlacePickUp> {

  ///Place details that include long and lat
  fetchClickedPlaceDetails(String placeID) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)  => LoadingDialog(messageText: "Getting Details"),
    );

    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";

    var responseFromDetailsPlaceAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if(responseFromDetailsPlaceAPI == "error"){
      return;
    }

    if(responseFromDetailsPlaceAPI["status"] == "OK"){
      AddressModel pickUpLocation = AddressModel();
      AddressModel dropOffLocation = AddressModel();

      pickUpLocation.placeName = responseFromDetailsPlaceAPI["result"]["name"];
      pickUpLocation.latitudePosition= responseFromDetailsPlaceAPI["result"]["geometry"]["location"]["lat"];
      pickUpLocation.longitudePosition= responseFromDetailsPlaceAPI["result"]["geometry"]["location"]["lng"];
      pickUpLocation.placeID= placeID;

      dropOffLocation.placeName = "Mega Pacific Freight Logistics, Inc.";
      dropOffLocation.latitudePosition = 14.481952540896081;
      dropOffLocation.longitudePosition = 121.05271356403014;
      dropOffLocation.placeID = "ChIJSyzcqjTPlzMRwKkQxkUfrXQ";

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(pickUpLocation);



      Navigator.pop(context, "pickUpSelected");

    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: (){
          fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),
                const SizedBox(width: 13,),

                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //main text
                    Text(
                      widget.predictedPlaceData!.main_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3,),
                    //secondary text
                    Text(
                      widget.predictedPlaceData!.secondary_text.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),

            const SizedBox(height: 10,),


          ],
        )
    );
  }
}
