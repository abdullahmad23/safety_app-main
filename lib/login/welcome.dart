import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velocity_x/velocity_x.dart';

import '../utilities/app_color.dart';
import 'login.dart';
import 'register.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                ClipRRect(
                    borderRadius: BorderRadius.circular(150.0),
                  child: Lottie.asset("assets/animation/safety.json", height: 150,)),
              Column(
                  children: [
                    "Welcome to".text.xl2.size(15).makeCentered(),
                    SizedBox(height: 15,),
                    "My Safety".text.bold.size(20).makeCentered(),
                  ],
                ),
                Image.asset("assets/images/welcome.png"),
                Column(
                  children: [
                    const Text(
                      "Let's get started",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15,),
                    Text(
                      "Safety, in its widest sense, concerns the happiness, contentment and freedom of mankind."
                          "Working safely is like breathing – if you don't, you die.",
                      style: TextStyle(
                          fontSize: 12,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 60,),
                Row(
                    children:[
                      Expanded(
                        child: SizedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const Register()),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Get Started',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      Expanded(
                        child: SizedBox(

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const Login()));
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                          ),
                        ),
                      ),
                    ]
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}