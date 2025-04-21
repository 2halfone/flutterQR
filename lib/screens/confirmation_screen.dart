import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async'; // Added for Timer
import 'package:http/http.dart' as http;
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart'; // Import for navigation to home screen

class ConfirmationScreen extends StatefulWidget {
  final String name;
  final String surname;

  const ConfirmationScreen({
    Key? key,
    required this.name,
    required this.surname,
  }) : super(key: key);

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isLoading = false;
  String? _responseMessage;
  bool _isSuccess = false;
  Timer? _redirectTimer;
  int _countdownValue = 3; // Countdown value

  // Define our tempered color scheme
  final positiveGreen = Colors.green.shade600;
  final absentRed = Colors.red.shade600;
  final titleBlack = Colors.black;
  final accentColor = Colors.blueGrey.shade600;

  @override
  void dispose() {
    _redirectTimer?.cancel(); // Cancel timer to avoid memory leaks
    super.dispose();
  }

  // Function to start countdown timer and redirect
  void _startRedirectCountdown() {
    _redirectTimer?.cancel();
    _countdownValue = 3;
    
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 0) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false, // Remove all previous routes
          );
        }
      }
    });
  }

  // Function to send attendance status to Apps Script
  Future<void> _sendAttendanceStatus(String status) async {
    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbzUZyMc8Ba7Q1GypBetribdIBjbvIzbm3vmXM7fZpF8aNsF9ApvEKzh_5vkq6PEVRfDEA/exec'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': widget.name,
          'surname': widget.surname,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 302) {
        final redirectMatch = RegExp(r'HREF="([^"]*)"').firstMatch(response.body);
        if (redirectMatch != null) {
          final redirectUrl = redirectMatch.group(1)!.replaceAll('&amp;', '&');
          
          try {
            final redirectResponse = await http.get(Uri.parse(redirectUrl));
            
            if (redirectResponse.statusCode == 200) {
              try {
                final jsonData = jsonDecode(redirectResponse.body);
                
                if (jsonData is Map && jsonData.containsKey('status')) {
                  final responseStatus = jsonData['status'];
                  final message = jsonData['message'] ?? '';
                  
                  if (responseStatus == 'success') {
                    setState(() {
                      _responseMessage = '✅ Presenza registrata con successo!';
                      _isSuccess = true;
                    });
                    _startRedirectCountdown();
                  } else if (responseStatus == 'error') {
                    if (message == 'already_registered') {
                      setState(() {
                        _responseMessage = 'Hai già registrato oggi';
                        _isSuccess = false;
                      });
                      _startRedirectCountdown();
                    } else {
                      setState(() {
                        _responseMessage = 'Errore: ${_getErrorMessage(message)}';
                        _isSuccess = false;
                      });
                      _startRedirectCountdown();
                    }
                  }
                  return;
                }
              } catch (e) {
                // Unable to parse JSON response, continuing with text-based parsing
                debugPrint('Error parsing JSON from redirect response: $e');
              }
              
              final redirectText = redirectResponse.body.toLowerCase();
              if (redirectText.contains('success')) {
                setState(() {
                  _responseMessage = '✅ Presenza registrata con successo!';
                  _isSuccess = true;
                });
                _startRedirectCountdown();
                return;
              } else if (redirectText.contains('already_registered')) {
                setState(() {
                  _responseMessage = 'Hai già registrato oggi';
                  _isSuccess = false;
                });
                _startRedirectCountdown();
                return;
              } else if (redirectText.contains('error:')) {
                final errorMatch = RegExp(r'error:([a-z_]+)').firstMatch(redirectText);
                if (errorMatch != null) {
                  final errorType = errorMatch.group(1);
                  setState(() {
                    _responseMessage = 'Errore: ${_getErrorMessage(errorType ?? "unknown")}';
                    _isSuccess = false;
                  });
                  _startRedirectCountdown();
                  return;
                }
              }
            }
          } catch (e) {
            // Failed to handle redirect URL
            debugPrint('Error handling redirect URL: $e');
          }
        }
      }
      
      try {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData is Map && jsonData.containsKey('status')) {
          // ... codice esistente per interpretare JSON ...
        }
      } catch (e) {
        // Failed to parse JSON from main response
        debugPrint('Error parsing JSON from main response: $e');
      }
      
      final responseText = response.body.toLowerCase();
      
      if (responseText.contains('success')) {
        setState(() {
          _responseMessage = '✅ Presenza registrata con successo!';
          _isSuccess = true;
        });
        _startRedirectCountdown();
      } else if (responseText.contains('already_registered')) {
        setState(() {
          _responseMessage = 'Hai già registrato oggi';
          _isSuccess = false;
        });
        _startRedirectCountdown();
      } else {
        setState(() {
          _responseMessage = 'Operazione completata';
          _isSuccess = true;
        });
        _startRedirectCountdown();
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Errore di rete: $e';
        _isSuccess = false;
      });
      _startRedirectCountdown();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'missing_body':
        return 'Missing data in request';
      case 'missing_parameters': 
        return 'Required parameters missing';
      case 'already_registered':
        return 'You have already registered today';
      case 'write_failed':
        return 'Error writing to the sheet';
      default:
        return 'Unknown error: $errorCode';
    }
  }

  Future<void> _showAbsenceReasonDialog() async {
    String selectedReason = 'Illness';
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Absence Reason',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.healing, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Illness',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Illness',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.event_available, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Appointment',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Appointment',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.local_hospital, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Hospital',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Hospital',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.family_restroom, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Family',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Family',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.beach_access, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Vacation',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Vacation',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.more_horiz, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Other',
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    value: 'Other',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedReason),
            child: Text(
              'CONFIRM',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (result != null) {
      _sendAttendanceStatus('Absent - $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Member Confirmation',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: titleBlack,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Rimuoviamo il gradiente viola/blu e lasciamo solo l'immagine di sfondo
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/geometric-pattern.png'),
            fit: BoxFit.cover,
          ),
          // Rimuoviamo completamente la proprietà gradient
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Check Icon using positive green
              Icon(
                Icons.check_circle,
                color: positiveGreen,
                size: 100,
              )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0), // Increased bottom margin
                child: Text(
                  'Member Verified',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: positiveGreen,
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, curve: Curves.easeOutBack)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
              ),
              const SizedBox(height: 20),
              // Elegant welcome message using italic style with accent color
              Text(
                'Welcome to Day Care Center',
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: accentColor,
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 10),
              // Display the name and surname
              Text(
                '${widget.name} ${widget.surname}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: titleBlack,
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              GlassmorphicContainer(
                width: double.infinity,
                height: 180,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 0, // Rimuove il bordo impostandolo a 0
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent, // Rende il bordo completamente trasparente
                    Colors.transparent, // Rende il bordo completamente trasparente
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm Attendance',
                        style: GoogleFonts.playfairDisplay(
                          color: accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () { _sendAttendanceStatus('Present'); },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: positiveGreen,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Stesso valore per entrambi
                                ),
                                elevation: 2, // Stessa elevazione
                              ),
                              child: Text(
                                'Present',
                                style: GoogleFonts.lato(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white, // Stesso colore di testo
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _showAbsenceReasonDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: absentRed,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Stesso valore per entrambi
                                ),
                                elevation: 2, // Stessa elevazione
                              ),
                              child: Text(
                                'Absent',
                                style: GoogleFonts.lato(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white, // Stesso colore di testo
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms, curve: Curves.easeOutBack)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              ),
              
              if (_isLoading)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Recording attendance...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_responseMessage != null)
                Column(
                  children: [
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 60,
                      borderRadius: 10,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _isSuccess ? positiveGreen.withValues(alpha: 0.1) : absentRed.withValues(alpha: 0.1),
                          _isSuccess ? positiveGreen.withValues(alpha: 0.05) : absentRed.withValues(alpha: 0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _isSuccess ? positiveGreen.withValues(alpha: 0.5) : absentRed.withValues(alpha: 0.5),
                          _isSuccess ? positiveGreen.withValues(alpha: 0.5) : absentRed.withValues(alpha: 0.5),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          _responseMessage!.startsWith('✅')
                              ? '✅ Attendance recorded successfully!'
                              : _responseMessage!.contains('già registrato')
                                  ? 'You have already registered today'
                                  : _responseMessage!,
                          style: GoogleFonts.lato(
                            color: _responseMessage!.startsWith('✅') ? positiveGreen : absentRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),
                    
                    // Countdown indicator
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Redirecting to home in $_countdownValue...',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      curve: Curves.easeInOut,
                    ),
                  ],
                ),
              
              const Spacer(),
              
              GlassmorphicContainer(
                width: 200,
                height: 50,
                borderRadius: 25,
                blur: 20,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.5),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(25),
                    child: Center(
                      child: Text(
                        'Back to Scanner',
                        style: GoogleFonts.lato(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(
                duration: 800.ms,
                curve: Curves.easeOutBack,
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}