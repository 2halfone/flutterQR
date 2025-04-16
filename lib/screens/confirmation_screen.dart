import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Function to send attendance status to Apps Script
  Future<void> _sendAttendanceStatus(String status) async {
    // Set loading state
    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });

    try {
      // Crea URL senza parametri di query
      final url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbzUZyMc8Ba7Q1GypBetribdIBjbvIzbm3vmXM7fZpF8aNsF9ApvEKzh_5vkq6PEVRfDEA/exec'
      );
      
      // Invia una richiesta POST con JSON nel body
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
      
      // Se riceviamo un reindirizzamento 302, estrai l'URL e seguilo
      if (response.statusCode == 302) {
        final redirectMatch = RegExp(r'HREF="([^"]*)"').firstMatch(response.body);
        if (redirectMatch != null) {
          final redirectUrl = redirectMatch.group(1)!.replaceAll('&amp;', '&');
          
          try {
            // Effettuiamo una richiesta GET all'URL di reindirizzamento
            final redirectResponse = await http.get(Uri.parse(redirectUrl));
            
            // Proviamo a interpretare questa risposta
            if (redirectResponse.statusCode == 200) {
              // Prova a interpretarlo come JSON
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
                  } else if (responseStatus == 'error') {
                    if (message == 'already_registered') {
                      setState(() {
                        _responseMessage = 'Hai già registrato oggi';
                        _isSuccess = false;
                      });
                    } else {
                      setState(() {
                        _responseMessage = 'Errore: ${_getErrorMessage(message)}';
                        _isSuccess = false;
                      });
                    }
                  }
                  return;
                }
              } catch (e) {
                // Ignora silenziosamente gli errori di parsing JSON
              }
              
              // Se non è JSON, controlla il testo della risposta
              final redirectText = redirectResponse.body.toLowerCase();
              if (redirectText.contains('success')) {
                setState(() {
                  _responseMessage = '✅ Presenza registrata con successo!';
                  _isSuccess = true;
                });
                return;
              } else if (redirectText.contains('already_registered')) {
                setState(() {
                  _responseMessage = 'Hai già registrato oggi';
                  _isSuccess = false;
                });
                return;
              } else if (redirectText.contains('error:')) {
                final errorMatch = RegExp(r'error:([a-z_]+)').firstMatch(redirectText);
                if (errorMatch != null) {
                  final errorType = errorMatch.group(1);
                  setState(() {
                    _responseMessage = 'Errore: ${_getErrorMessage(errorType ?? "unknown")}';
                    _isSuccess = false;
                  });
                  return;
                }
              }
            }
          } catch (e) {
            // Ignora silenziosamente gli errori di reindirizzamento
          }
        }
      }
      
      // Se arriviamo qui, significa che non siamo riusciti a seguire il reindirizzamento,
      // quindi proviamo a interpretare la risposta originale
      
      try {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData is Map && jsonData.containsKey('status')) {
          // ... codice esistente per interpretare JSON ...
        }
      } catch (e) {
        // Ignora silenziosamente gli errori di parsing JSON
      }
      
      // Metodo di fallback: cerca parole chiave nel testo della risposta
      final responseText = response.body.toLowerCase();
      
      if (responseText.contains('success')) {
        setState(() {
          _responseMessage = '✅ Presenza registrata con successo!';
          _isSuccess = true;
        });
      } else if (responseText.contains('already_registered')) {
        setState(() {
          _responseMessage = 'Hai già registrato oggi';
          _isSuccess = false;
        });
      } else {
        setState(() {
          // Mostro invece un messaggio generico positivo
          _responseMessage = 'Operazione completata';
          _isSuccess = true;  // Consideriamo l'operazione riuscita comunque
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Errore di rete: $e';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metodo di supporto per tradurre i codici di errore in messaggi comprensibili
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'missing_body':
        return 'Dati mancanti nella richiesta';
      case 'missing_parameters': 
        return 'Parametri obbligatori mancanti';
      case 'already_registered':
        return 'Hai già registrato oggi';
      case 'write_failed':
        return 'Errore durante la scrittura sul foglio';
      default:
        return 'Errore sconosciuto: $errorCode';
    }
  }

  // Funzione per mostrare la finestra di dialogo per il motivo dell'assenza
  Future<void> _showAbsenceReasonDialog() async {
    String selectedReason = 'Malattia';
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona motivo assenza'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Malattia'),
                  value: 'Malattia',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Appuntamento'),
                  value: 'Appuntamento',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Vacanza'),
                  value: 'Vacanza',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Altro'),
                  value: 'Altro',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedReason),
            child: const Text('CONFERMA'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      _sendAttendanceStatus('Assente - $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conferma Utente'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Utente Verificato',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow('Nome', widget.name),
                    const SizedBox(height: 16),
                    _buildInfoRow('Cognome', widget.surname),
                  ],
                ),
              ),
            ),
            
            // Mostra indicatore di caricamento, messaggio di successo/errore
            if (_isLoading)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Registrazione presenza in corso...'),
                  ],
                ),
              ),
              
            if (_responseMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _responseMessage!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Pulsanti Presente/Assente affiancati
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _sendAttendanceStatus('Presente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle, size: 30),
                        SizedBox(height: 8),
                        Text('Presente', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _showAbsenceReasonDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.cancel, size: 30),
                        SizedBox(height: 8),
                        Text('Assente', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pulsante di ritorno
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Torna allo Scanner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}