import 'package:flutter/material.dart';
import 'vercel_app_view.dart'; 
import 'scan_screen.dart';
import 'daycare_qr_scanner_page.dart'; // Importo la nuova pagina

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Dashboard')),
      body: Align(
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
                  // 3: bottom‑right +50px
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: _buildHalfSizeOptionCard(
                        context,
                        icon: Icons.elderly,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DayCareQrScannerPage()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // 5° bottone: calendario
              Expanded(
                child: SizedBox(
                  width: 336,    // 160 + 16 + 160
                  child: _buildOptionCard(
                    context,
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: azione quinto bottone
                    },
                  ),
                ),
              ),
            ],
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
    return Card(
      elevation: 4,
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
    );
  }

  Widget _buildHalfSizeOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
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
    );
  }
}