import 'package:flutter/material.dart';
import 'package:mon_projet/screens/loginscreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Simple 3‑page onboarding carousel shown after the splash.
class onboardingscreen extends StatefulWidget {
  const onboardingscreen({super.key});

  @override
  State<onboardingscreen> createState() => _onboardingscreenState();
}

class _onboardingscreenState extends State<onboardingscreen> {
  final PageController controlleronboard = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) {
              setState(() {
                isLastPage = value ==2;
              });
            },            
            controller: controlleronboard,
            children: [
              // TODO: Replace colored containers with real designs/content.
              Container(
                color: Colors.blue,
                child: const Center(child: Text('Page 1'),),
              ),
              Container(
                color: Colors.red,
                child: const Center(child: Text('Page 2'),),
              ),
              Container(
                color: Colors.green,
                child: const Center(child: Text('Page 3'),),
              ),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.89),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 10),
                GestureDetector(
                  child: Text("skip"),
                  onTap: (){
                    controlleronboard.jumpToPage(2);
                  },
                  ),
                SmoothPageIndicator(controller: controlleronboard, 
                count: 3,
                effect: WormEffect(
                  dotHeight: 7,
                  dotWidth: 24,
                  dotColor: Colors.blueGrey,
                  activeDotColor: Colors.white,
                  paintStyle: PaintingStyle.fill,
                ),
                ),
            
                
                isLastPage 
                  ? GestureDetector
                  (child: Text("done"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Loginscreen()),
                      ),
                  
                  )
                
                 
                 : GestureDetector(
                    child: Text("next"),
                    onTap: (){
                    controlleronboard.nextPage(
                      duration: Duration(microseconds: 500), 
                      curve: Curves.easeIn);
                },
                ),
                SizedBox(width: 10),
              ],
            ),
          )
        ],
      ),
    );
  }
}