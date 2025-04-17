import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui'; // for ImageFilter
import 'vercel_app_view.dart'; 
import 'scan_screen.dart';
import 'daycare_qr_scanner_page.dart'; // Importo la nuova pagina
import 'calendar_page.dart';  // ← aggiunto


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
                child: Container(color: Colors.white.withOpacity(0.2)),
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
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage('assets/images/sfondo_bottone5.png'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.2),
                                    BlendMode.srcOver,
                                  ),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.purple.withOpacity(0.3),
                                  highlightColor: Colors.purple.withOpacity(0.1),
                                  child: Center(
                                    child: Icon(Icons.qr_code_scanner, size: 60, color: Colors.purple),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // 2: top‑right +50px
                          Padding(
                            padding: EdgeInsets.only(top: buttonOffset),
                            child: SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/sfondo_bottone4.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.2),
                                      BlendMode.srcOver,
                                    ),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Dynamic QR codes will be available soon!'),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.grey.withOpacity(0.3),
                                    highlightColor: Colors.grey.withOpacity(0.1),
                                    child: Center(
                                      child: Icon(Icons.qr_code_scanner, size: 60, color: Colors.grey),
                                    ),
                                  ),
                                ),
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
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage('assets/images/sfondo_bottone3.png'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.2),
                                    BlendMode.srcOver,
                                  ),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const VercelAppView()),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.blue.withOpacity(0.3),
                                  highlightColor: Colors.blue.withOpacity(0.1),
                                  child: SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          // 3: bottom‑right +50px, Day Care with custom background
                          Padding(
                            padding: EdgeInsets.only(top: buttonOffset),
                            child: SizedBox(
                              width: buttonSize,
                              height: buttonSize,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.15), // un po’ più intensa
    blurRadius: 10, // più morbida
    offset: Offset(0, 6), // un po’ più “sollevata”
  ),
],

                                  image: DecorationImage(
                                    image: AssetImage('assets/images/sfondo_bottone2.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.srcOver,
                                    ),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const DayCareQrScannerPage(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.teal.withOpacity(0.3),
                                    highlightColor: Colors.teal.withOpacity(0.1),
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
                            ),
                          ),
                        ],
                      ),
                      // spazio minimo sopra il rettangolo
                      const SizedBox(height: 16.0),
                      // 5° rettangolo: calendario responsivo con bottom margin fisso
                      Flexible(
                        fit: FlexFit.tight,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: AspectRatio(
                              aspectRatio: 366 / 290,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/sfondo_bottone.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.srcOver,
                                    ),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CalendarPage()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.orange.withOpacity(0.3),
                                    highlightColor: Colors.orange.withOpacity(0.1),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Center(
            child: Icon(icon, size: 60, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildHalfSizeOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Center(
            child: Icon(icon, size: 60, color: color),
          ),
        ),
      ),
    );
  }
}