import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui'; // for ImageFilter
import 'vercel_app_view.dart'; 
import 'scan_screen.dart';
import 'daycare_qr_scanner_page.dart'; // Importo la nuova pagina
import 'calendar_page.dart';  // ← aggiunto
import 'personal_page.dart';  // ← aggiunto per la pagina personale


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxGridWidth = 700.0; // optional cap to prevent overly large buttons
    // Grid occupies 90% of screen width, capped at maxGridWidth
    final gridWidth = min(screenWidth * 0.9, maxGridWidth);
    const maxButtonSize = 160.0;
    const minButtonSize = 50.0;
    const totalHorizontalPadding = 80.0; // 20px padding on both sides + 20px between buttons
    final rawButtonSize = (gridWidth - totalHorizontalPadding) / 2;
    final buttonSize = screenWidth < 400
        ? rawButtonSize.clamp(minButtonSize, maxButtonSize)
        : rawButtonSize.clamp(0.0, maxButtonSize);
    final buttonOffset = buttonSize * (50 / 160);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'The Community Hub',
          style: TextStyle(
            fontFamily: 'jsMath-cmmi10',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
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
                child: Container(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,  // Riempe verticalmente
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              splashColor: Colors.purple.withValues(alpha: 0.3),
                              highlightColor: Colors.purple.withValues(alpha: 0.1),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // 2: top‑right +50px
                          Padding(
                            padding: EdgeInsets.only(top: buttonOffset),
                            child: SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: _buildNeumorphicButton(
                                backgroundImage: 'assets/images/sfondo_bottone4.png',
                                icon: Icons.person, // Cambiato da qr_code_scanner a person
                                iconColor: Colors.grey,
                                splashColor: Colors.grey.withValues(alpha: 0.3),
                                highlightColor: Colors.grey.withValues(alpha: 0.1),
                                onTap: () {
                                  // Cambiato da SnackBar a navigazione verso PersonalPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PersonalPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      // seconda riga
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 4: bottom‑left
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: _buildNeumorphicButton(
                              backgroundImage: 'assets/images/sfondo_bottone3.png',
                              splashColor: Colors.blue.withValues(alpha: 0.3),
                              highlightColor: Colors.blue.withValues(alpha: 0.1),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VercelAppView()),
                                );
                              },
                              child: const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // 3: bottom‑right +50px, Day Care with custom background
                          Padding(
                            padding: EdgeInsets.only(top: buttonOffset),
                            child: SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: _buildNeumorphicButton(
                                backgroundImage: 'assets/images/sfondo_bottone2.png',
                                deeper: true,
                                splashColor: Colors.teal.withValues(alpha: 0.3),
                                highlightColor: Colors.teal.withValues(alpha: 0.1),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DayCareQrScannerPage(),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
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
                            ),
                          ),
                        ],
                      ),
                      // spazio minimo sopra il rettangolo
                      const SizedBox(height: 16.0),
                      // 5° rettangolo: calendario responsivo con bottom margin fisso
                      Flexible(
                        fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 65.0), // Changed from the implicit 0px to 40px
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              widthFactor: 0.9,
                              child: AspectRatio(
                                aspectRatio: 366 / 290,
                                child: _buildNeumorphicButton(
                                  backgroundImage: 'assets/images/sfondo_bottone.png',
                                  splashColor: Colors.orange.withValues(alpha: 0.3),
                                  highlightColor: Colors.orange.withValues(alpha: 0.1),
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
                        ),
                      ),
                    ],
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
                                MaterialPageRoute(builder: (_) => const ScanScreen()),
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
                                MaterialPageRoute(builder: (_) => const CalendarPage()),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: _buildNavBarItem(
                            icon: Icons.admin_panel_settings_rounded,
                            label: "Admin",
                            color: Colors.blue,
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
            color: Colors.black.withValues(alpha: deeper ? 0.15 : 0.1),
            blurRadius: deeper ? 10 : 6,
            offset: Offset(0, deeper ? 6 : 3),
            spreadRadius: deeper ? 1 : 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: deeper ? 0.5 : 0.2),
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
          child: child ?? (icon != null ? Center(
            child: Icon(icon, size: 60, color: iconColor),
          ) : null),
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