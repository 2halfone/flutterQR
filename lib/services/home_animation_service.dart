import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flip_card/flip_card.dart';

/// Servizio per gestire le animazioni nella home page
class HomeAnimationService {
  // Rimossa la logica per l'animazione della campanella
  late GlobalKey<FlipCardState> dayCareFlipKey;
  late Timer dayCareFlipTimer;
  
  /// Inizializza e gestisce il flip automatico della card DayCare
  void initFlipCardAnimation() {
    dayCareFlipKey = GlobalKey<FlipCardState>();
    dayCareFlipTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      dayCareFlipKey.currentState?.toggleCard();
    });
  }
  
  /// Libera le risorse utilizzate per le animazioni
  void dispose() {
    dayCareFlipTimer.cancel();
  }
}