import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Servizio per la costruzione dei componenti UI della home page
class HomeUiBuilderService {
  /// Costruisce un pulsante con effetto neumorphic personalizzato
  Widget buildNeumorphicButton({
    required String backgroundImage,
    IconData? icon,
    Color iconColor = Colors.white,
    Color splashColor = Colors.white,
    Color highlightColor = Colors.white,
    required VoidCallback onTap,
    Widget? child,
    bool deeper = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(deeper ? 0.15 : 0.1),
            blurRadius: deeper ? 10 : 6,
            offset: Offset(0, deeper ? 6 : 3),
            spreadRadius: deeper ? 1 : 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(deeper ? 0.5 : 0.2),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: splashColor,
          highlightColor: highlightColor,
          child: child ??
              (icon != null
                  ? Center(
                      child: Icon(icon, size: 60, color: iconColor),
                    )
                  : null),
        ),
      ),
    );
  }

  /// Costruisce un elemento della barra di navigazione
  Widget buildNavBarItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isActive ? 25 : 19,
            color: Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isActive ? 14 : 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Costruisce la card "Our Story" con tutti i suoi contenuti
  Widget buildStoryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Journey',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Divider(color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              'Four decades of community service and counting',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              'The Community Hub is a welcoming space for people of all ages, genders and ethnicities to come together, stay safe and active and feel included and valued.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              'Set up by the Council of Asian People in 1982 and previously known as The Asian Centre, the Hub, located in the heart of Haringey borough, and its staff and Board members work diligently to fulfil its goal to support and ensure people live an active and healthy life.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              '1982\nFounded with a Mission\nEstablished by the Council of Asian People to serve the diverse community of Haringey',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.4),
            ),
            Text(
              '37 years on the organisation continues to offer services to the diverse community in and around Haringey, focusing particularly, through its activities events, on the physical and emotional well-being and cohesion of people.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              'It also provides key support for vulnerable and marginalised residents in the area and maintains an open door, drop-in policy for anyone who is in need of advice and or support.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              '"We welcome all to join our organisation and become a member. As a member you get discounts on charges for classes and trips and regularly receive news about events and activities taking place at the Hub."',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.6),
            ),
            Text(
              'From time to time, your views are sought to help us keep providing suitable and stimulating services.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            Text(
              'Join Our Community',
              textAlign: TextAlign.justify,
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Our Journey Through the Years',
              textAlign: TextAlign.justify,
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '1982\nFoundation\nEstablished as The Asian Centre by the Council of Asian People',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            Text(
              '2000s\nGrowth & Expansion\nExpanded services to meet the evolving needs of our diverse community',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, height: 1.4),
            ),
            Text(
              'Today\nThe Community Hub\nA vibrant center supporting physical and emotional wellbeing for all',
              textAlign: TextAlign.justify,
              style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}