import 'package:flutter/material.dart';
// Import di preview_screen.dart rimosso perché non più necessario

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Rimossa la scritta "Welcome to QR Code Customizer"
              const Center(
                child: Text(
                  'Choose the type of QR code you want to create',
                  style: TextStyle(
                    fontSize: 18, // Aumentata leggermente la dimensione
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildOptionCard(
                context,
                title: 'QR Code Customizer',
                description: 'Create a QR code with fixed content that cannot be changed after creation.',
                icon: Icons.qr_code,
                color: Colors.blue,
                onTap: () {
                  // Rimosso il reindirizzamento a PreviewScreen
                  // Sostituito con un messaggio temporaneo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funzionalità in fase di aggiornamento'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Row con due bottoni di dimensioni uguali per Dynamic QR e Static QR Code
              Row(
                children: [
                  // Dynamic QR button
                  Expanded(
                    child: _buildHalfSizeOptionCard(
                      context,
                      title: 'Dynamic QR',
                      icon: Icons.qr_code_scanner,
                      color: Colors.grey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dynamic QR codes will be available soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Static QR Code button
                  Expanded(
                    child: _buildHalfSizeOptionCard(
                      context,
                      title: 'Static QR Code',
                      icon: Icons.qr_code,
                      color: Colors.teal,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Static QR Code functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                title: 'QR Code Scanner',
                description: 'Scan QR codes using your camera.',
                icon: Icons.qr_code_scanner,
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code Scanner coming soon!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 60,
                color: color,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHalfSizeOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 60,
                color: color,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}