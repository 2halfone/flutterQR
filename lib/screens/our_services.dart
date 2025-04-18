import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OurServicesPage extends StatelessWidget {
  const OurServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': Icons.design_services,
        'title': 'Consulting',
        'description': 'Expert advice to grow your business.'
      },
      {
        'icon': Icons.build,
        'title': 'Development',
        'description': 'Custom solutions built for you.'
      },
      {
        'icon': Icons.support,
        'title': 'Support',
        'description': '24/7 help whenever you need it.'
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Our Services',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              service['icon'] as IconData,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              service['title'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              service['description'] as String,
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}