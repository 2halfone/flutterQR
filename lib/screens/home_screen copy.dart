// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui'; // for ImageFilter
import 'vercel_app_view.dart';
import 'scan_screen.dart';
import 'daycare_qr_scanner_page.dart'; // Importo la nuova pagina
import 'calendar_page.dart'; // ← aggiunto
import 'personal_page.dart'; // ← aggiunto per la pagina personale
import 'package:google_fonts/google_fonts.dart';
import 'our_services.dart'; // Add import for the new page
import 'dart:async';
import 'package:flip_card/flip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late Animation<double> _bellAnimation;
  bool _showStory = false; // toggle visibility

  // Nuovi campi per il flip automatico
  late GlobalKey<FlipCardState> _dayCareFlipKey;
  late Timer _dayCareFlipTimer;

  @override
  void initState() {
    super.initState();

    // Controller con durata più lunga per un movimento più naturale
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 800), // Durata aumentata
      vsync: this,
    );

    // Animazione più naturale con oscillazione dinamica
    _bellAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.15)
            .chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 25.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.15, end: -0.15)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.15, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInSine)),
        weight: 25.0,
      ),
    ]).animate(_bellController);

    // Avvio dell'animazione con un leggero ritardo iniziale
    Future.delayed(const Duration(milliseconds: 500), () {
      _bellController.repeat();
    });

    _dayCareFlipKey = GlobalKey<FlipCardState>();
    _dayCareFlipTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _dayCareFlipKey.currentState?.toggleCard();
    });
  }

  @override
  void dispose() {
    _dayCareFlipTimer.cancel();
    _bellController.dispose();
    super.dispose();
  }

  Widget _buildGridAndCalendarSection(
      double buttonSize, double buttonOffset, double contentWidth) {
    return Column(
      children: [
        // prima riga
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1: top‑left
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone5.png',
                icon: Icons.qr_code_scanner,
                iconColor: Colors.purple,
                splashColor: Colors.purple.withOpacity(0.3),
                highlightColor: Colors.purple.withOpacity(0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10.0),
            // 2: top‑right
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone4.png',
                icon: Icons.person,
                iconColor: Colors.grey,
                splashColor: Colors.grey.withOpacity(0.3),
                highlightColor: Colors.grey.withOpacity(0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonalPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        // seconda riga
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 4: bottom‑left
            Padding(
              padding: EdgeInsets.only(bottom: buttonOffset),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: _buildNeumorphicButton(
                  backgroundImage: 'assets/images/sfondo_bottone3.png',
                  splashColor: Colors.blue.withOpacity(0.3),
                  highlightColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VercelAppView()),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            // 3: bottom‑right +50px, Day Care with FlipCard
            Padding(
              padding: EdgeInsets.only(top: buttonOffset),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: FlipCard(
                  key: _dayCareFlipKey,
                  flipOnTouch: false,
                  front: _buildNeumorphicButton(
                    backgroundImage: 'assets/images/sfondo_bottone2.png',
                    deeper: true,
                    splashColor: Colors.teal.withOpacity(0.3),
                    highlightColor: Colors.teal.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DayCareQrScannerPage(),
                        ),
                      );
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Day Care',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  back: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent, // sfondo trasparente
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/daycar.png',
                        width: buttonSize *
                            0.8, // icona più piccola rispetto al bottone
                        height: buttonSize * 0.8,
                        fit: BoxFit.contain, // mantiene le proporzioni e centra
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // 5° rettangolo: calendario responsivo con bottom margin fisso
        Padding(
          padding: const EdgeInsets.only(bottom: 65.0),
          child: SizedBox(
            width: contentWidth,
            child: AspectRatio(
              aspectRatio: 366 / 290,
              child: _buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone.png',
                splashColor: Colors.orange.withOpacity(0.3),
                highlightColor: Colors.orange.withOpacity(0.1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CalendarPage()),
                  );
                },
                child: const Center(
                  child: Icon(
                    Icons.calendar_today,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxGridWidth = 700.0; // optional cap to prevent overly large buttons
    final gridWidth = min(screenWidth * 0.9, maxGridWidth);
    final contentWidth = screenWidth > 850 ? 800.0 : screenWidth * 0.9;
    const maxButtonSize = 160.0;
    const minButtonSize = 50.0;
    const totalHorizontalPadding =
        80.0; // 20px padding on both sides + 20px between buttons
    final rawButtonSize = (gridWidth - totalHorizontalPadding) / 2;
    final buttonSize = screenWidth < 400
        ? rawButtonSize.clamp(minButtonSize, maxButtonSize)
        : rawButtonSize.clamp(0.0, maxButtonSize);
    final buttonOffset = buttonSize * (50 / 160);

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Rimozione dell'AppBar
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/india-pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max, // Riempe verticalmente
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Card al top della pagina
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            width: contentWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.purple.withOpacity(0.7),
                                  Colors.blue.withOpacity(0.5),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _bellAnimation,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _bellAnimation.value,
                                              child: const Icon(
                                                Icons.notifications_active,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Welcome to",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              "THE COMMUNITY HUB",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Explore available services and discover upcoming events",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const OurServicesPage()),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        "Learn more",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Toggle button for Our Story
                        TextButton(
                          onPressed: () =>
                              setState(() => _showStory = !_showStory),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'Our Story',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Animated container for story card
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _showStory
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 5,
                                    color: Colors.white.withOpacity(0.2),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30.0, vertical: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Our Journey',
                                              textAlign: TextAlign.center,
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                      color: Colors.white,
                                                      fontSize: 26,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          const Divider(color: Colors.white54),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Four decades of community service and counting',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
                                          ),
                                          Text(
                                            'The Community Hub is a welcoming space for people of all ages, genders and ethnicities to come together, stay safe and active and feel included and valued.',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
                                          ),
                                          Text(
                                            'Set up by the Council of Asian People in 1982 and previously known as The Asian Centre, the Hub, located in the heart of Haringey borough, and its staff and Board members work diligently to fulfil its goal to support and ensure people live an active and healthy life.',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
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
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
                                          ),
                                          Text(
                                            'It also provides key support for vulnerable and marginalised residents in the area and maintains an open door, drop-in policy for anyone who is in need of advice and or support.',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
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
                                            style: GoogleFonts.openSans(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                height: 1.6),
                                          ),
                                          Text(
                                            'Join Our Community',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.playfairDisplay(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Our Journey Through the Years',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.playfairDisplay(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '1982\nFoundation\nEstablished as The Asian Centre by the Council of Asian People',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4),
                                          ),
                                          Text(
                                            '2000s\nGrowth & Expansion\nExpanded services to meet the evolving needs of our diverse community',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4),
                                          ),
                                          Text(
                                            'Today\nThe Community Hub\nA vibrant center supporting physical and emotional wellbeing for all',
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.openSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        _buildGridAndCalendarSection(
                            buttonSize, buttonOffset, contentWidth),
                        const SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          child: _buildNavBarItem(
                            icon: Icons.home_rounded,
                            label: "Home",
                            color: Colors.purple,
                            isActive: true,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _buildNavBarItem(
                            icon: Icons.qr_code_scanner_rounded,
                            label: "Scan",
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ScanScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _buildNavBarItem(
                            icon: Icons.calendar_today_rounded,
                            label: "Calendar",
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CalendarPage()),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _buildNavBarItem(
                            icon: Icons.qr_code_2,
                            label: "QR Editor",
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const VercelAppView()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton({
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

  Widget _buildNavBarItem({
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
            size: isActive ? 30 : 24,
            color: Colors.white, // Cambiato in bianco per tutte le icone
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isActive ? 14 : 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: Colors.white, // Cambiato in bianco per tutto il testo
            ),
          ),
        ],
      ),
    );
  }
}
