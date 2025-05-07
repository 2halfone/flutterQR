// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui'; // for ImageFilter
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

// Import dei servizi modulari
import '../services/home_animation_service.dart';
import '../services/home_ui_builder_service.dart';
import '../services/home_navigation_service.dart';
import '../services/home_layout_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Istanze dei servizi modulari
  final HomeAnimationService _animationService = HomeAnimationService();
  final HomeUiBuilderService _uiBuilderService = HomeUiBuilderService();
  final HomeNavigationService _navigationService = HomeNavigationService();
  final HomeLayoutService _layoutService = HomeLayoutService();
  
  bool _showStory = false; // toggle visibility per "Our Story"
  
  // Controller per l'animazione del bottone "Our Story"
  late AnimationController _storyButtonController;
  late Animation<double> _storyButtonAnimation;

  @override
  void initState() {
    super.initState();
    _animationService.initFlipCardAnimation();
    
    // Inizializza il controller dell'animazione
    _storyButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Crea l'animazione di rotazione
    _storyButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, // Rotazione completa (2π radianti)
    ).animate(CurvedAnimation(
      parent: _storyButtonController,
      curve: Curves.easeInOut,
    ));
    
    // Avvia l'animazione quando la pagina viene caricata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storyButtonController.forward();
    });
  }

  @override
  void dispose() {
    _animationService.dispose();
    _storyButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcolo delle dimensioni di layout
    final dimensions = _layoutService.calculateLayoutDimensions(context);
    final contentWidth = dimensions['contentWidth'];
    final buttonSize = dimensions['buttonSize'];
    final buttonOffset = dimensions['buttonOffset'];

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Card al top della pagina con animazione di discesa
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
                                        child: const Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      onPressed: () => _navigationService.navigateToOurServicesPage(context),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
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
                        )
                        .animate()
                        .slideY(
                          begin: -1.0, // Inizia fuori dallo schermo in alto
                          end: 0.0, // Finisce nella sua posizione naturale
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                          delay: 300.ms, // Leggero ritardo per dare un effetto più naturale
                        )
                        .fadeIn(
                          duration: 600.ms,
                          curve: Curves.easeInOut,
                        ),
                        // Toggle button for Our Story
                        AnimatedBuilder(
                          animation: _storyButtonAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _storyButtonAnimation.value,
                              child: child,
                            );
                          },
                          child: TextButton(
                            onPressed: () => setState(() => _showStory = !_showStory),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        ),
                        // Animated container for story card
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _showStory
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  child: _uiBuilderService.buildStoryCard(),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Grid section
                        _layoutService.buildGridAndCalendarSection(
                          context,
                          buttonSize,
                          buttonOffset,
                          contentWidth,
                          _animationService,
                          _navigationService.navigateToScanScreen,
                          _navigationService.navigateToPersonalPage,
                          _navigationService.navigateToVercelAppView,
                          _navigationService.navigateToDayCareQrScannerPage,
                          _navigationService.navigateToCalendarPage,
                        ),
                        const SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom navigation bar
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
                          child: _uiBuilderService.buildNavBarItem(
                            icon: Icons.home_rounded,
                            label: "Home",
                            color: Colors.purple,
                            isActive: true,
                            onTap: () {},
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _uiBuilderService.buildNavBarItem(
                            icon: Icons.qr_code_scanner_rounded,
                            label: "Scan",
                            color: Colors.teal,
                            onTap: () => _navigationService.navigateToScanScreen(context),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _uiBuilderService.buildNavBarItem(
                            icon: Icons.calendar_today_rounded,
                            label: "Calendar",
                            color: Colors.orange,
                            onTap: () => _navigationService.navigateToCalendarPage(context),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _uiBuilderService.buildNavBarItem(
                            icon: Icons.qr_code_2,
                            label: "QR Editor",
                            color: Colors.blue,
                            onTap: () => _navigationService.navigateToVercelAppView(context),
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
}
