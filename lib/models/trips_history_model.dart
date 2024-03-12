class TripHistoryModel{
  String? tripID;
  String? driverName;
  String? driverPhoto;
  String? date;
  String? pickUpPhoto;
  String? dropOffPhoto;
  String? driverPhone;
  String? pickUpAddress;

  TripHistoryModel({this.tripID, this.date, this.driverName, this.driverPhone, this.driverPhoto, this.dropOffPhoto, this.pickUpPhoto, this.pickUpAddress});

  void dispose(){
    tripID = null;
    driverName = null;
    driverPhoto = null;
    date = null;
    pickUpPhoto = null;
    dropOffPhoto = null;
    driverPhone = null;
    pickUpAddress = null;
  }
}


