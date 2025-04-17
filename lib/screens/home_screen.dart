import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vercel_app_view.dart'; 
import 'scan_screen.dart';
import 'daycare_qr_scanner_page.dart'; // Importo la nuova pagina
import 'calendar_page.dart';  // ← aggiunto

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'The Community Hub',
          style: GoogleFonts.playfairDisplay(
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
        child: SafeArea(
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
                        width: 160,
                        height: 160,
                        child: _buildOptionCard(
                          context,
                          icon: Icons.qr_code_scanner,
                          color: Colors.purple,
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
                        padding: const EdgeInsets.only(top: 50.0),
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: _buildHalfSizeOptionCard(
                            context,
                            icon: Icons.qr_code_scanner,
                            color: Colors.grey,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Dynamic QR codes will be available soon!'),
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
                        width: 160,
                        height: 160,
                        child: _buildOptionCard(
                          context,
                          icon: Icons.qr_code,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VercelAppView()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // 3: bottom‑right +50px, Day Care with custom background
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
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
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.elderly, size: 60, color: Colors.teal),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Day Care',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
                  // 5° rettangolo: calendario con dimensioni fisse
                  SizedBox(
                    width: 366,   // +10px rispetto alla griglia originale (336)
                    height: 290,   // -20px rispetto all’altezza precedente (80)
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
                ],
              ),
            ),
          ),
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
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: Offset(0, 12),
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
            blurRadius: 8,
            offset: Offset(0, 4),
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