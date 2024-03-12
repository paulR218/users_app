import 'package:flutter/material.dart';

class tripPhoto extends StatelessWidget {
  final String? photo;
  const tripPhoto({super.key, this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Proof"),
      ),
      body: FittedBox(
        child:
            photo == "No photo" ?
            const Text(
                "No photo is uploaded",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30
              ),
            )
        : Image.network(photo!)
      ),
    );
  }
}
