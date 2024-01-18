import 'package:flutter/material.dart';
import 'package:users_app/models/prediction_model.dart';

class PredictionPlaceUI extends StatefulWidget {

  PredictionModel? predictedPlaceData;

  PredictionPlaceUI({super.key, this.predictedPlaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: (){},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: Container(
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
          ),
        )
    );
  }
}
