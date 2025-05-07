import 'package:flutter/material.dart';
import '../screens/vercel_app_view.dart';
import '../screens/scan_screen.dart';
import '../screens/daycare_qr_scanner_page.dart';
import '../screens/calendar_page.dart';
import '../screens/personal_page.dart';
import '../screens/our_services.dart';

/// Servizio per gestire le operazioni di navigazione dalla home page
class HomeNavigationService {
  /// Naviga alla pagina di scansione QR
  void navigateToScanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }
  
  /// Naviga alla pagina personale
  void navigateToPersonalPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PersonalPage()),
    );
  }
  
  /// Naviga alla vista dell'app Vercel
  void navigateToVercelAppView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VercelAppView()),
    );
  }
  
  /// Naviga alla pagina DayCare QR Scanner
  void navigateToDayCareQrScannerPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DayCareQrScannerPage()),
    );
  }
  
  /// Naviga alla pagina calendario
  void navigateToCalendarPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarPage()),
    );
  }
  
  /// Naviga alla pagina dei servizi
  void navigateToOurServicesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OurServicesPage()),
    );
  }
}