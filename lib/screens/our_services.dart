import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'home_screen.dart';

class OurServicesPage extends StatelessWidget {
  const OurServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 850 ? 800.0 : screenWidth * 0.9;

    final services = [
      {
        'icon': Icons.design_services,
        'title': 'Day Care',
        'description': 'Haringey Community Hub Day Care Service was set up on the 17th October 1997 for older people with long-term illnesses and those with a disability.'
      },
      {
        'icon': Icons.build,
        'title': 'Van Hire',
        'description': 'The van has a lift, restraint points for securely holding a wheelchair in place and seat belts for passengers in wheelchairs'
      },
      {
        'icon': Icons.support,
        'title': 'Room Hire',
        'description': 'Our versatile spaces can accommodate groups of various sizes, from intimate gatherings of 5-10 people to larger events of up to 50 attendees.'
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // 1) Sfondo sotto a tutto
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/frog-pattern.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2) Contenuto scrollabile
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Center(
                child: Container(
                  width: contentWidth,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Our Services',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // carousel
                      FanCarouselImageSlider.sliderType2(
                        imagesLink: const [
                          'assets/images/hands-2906458_640.jpg',
                          'assets/images/home-van-300x196-1.png',
                          'assets/images/meeting-room.jpg',
                        ],
                        isAssets: true,
                        autoPlay: true,
                        sliderHeight: MediaQuery.of(context).size.height * 0.4,
                        imageRadius: 15,
                        slideViewportFraction: 0.9,
                        sliderDuration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 20),

                      // services list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20.0),
                        itemCount: services.length,
                        itemBuilder: (context, i) {
                          final svc = services[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(
                                svc['icon'] as IconData,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                svc['title'] as String,
                                style: GoogleFonts.playfairDisplay(),
                              ),
                              subtitle: Text(
                                svc['description'] as String,
                                style: GoogleFonts.openSans(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3) Back button **ultimi** in lista = in primo piano
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}