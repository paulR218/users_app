import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:http/http.dart' as http;
import 'package:users_app/models/address_model.dart';

class CommonMethods{
  checkConnectivity(BuildContext context) async {
      var connectionResult = await Connectivity().checkConnectivity();

      if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi){
        if(!context.mounted) return;
        displaySnackbar("You are not connected to the Internet.", context);
      }
  }

  displaySnackbar(String messageText, BuildContext context){
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try{
      if(responseFromAPI.statusCode == 200){
        String dataFromAPI = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromAPI);
        return dataDecoded;
      }
      else{
        return "error";
      }
    }
    catch(errorMsg){
      return "error";
    }
  }

  static Future<String> convertGeographicCoordinatesIntoHumanReadableAddress(Position position, BuildContext context) async {
    String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    String humanReadableAddress = "";
    var responseFromApi = await sendRequestToAPI(apiGeoCodingUrl);

    if(responseFromApi != "error"){
      humanReadableAddress = responseFromApi["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

}