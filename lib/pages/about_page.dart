import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}


class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Developed by: ",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.grey,),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/logo(old).png"),

            const SizedBox(height: 10,),

             const Padding(
             padding: EdgeInsets.all(4.0),
             child: Text(
                "This app is developed by: \n"
                    "Paul Anthony P. Rivera\n"
                    "Jonathan A. Agoo\n"
                    "Jonathan C. Lee\n"
                    "Renz Joshua S. Lanuza",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 22,

              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
