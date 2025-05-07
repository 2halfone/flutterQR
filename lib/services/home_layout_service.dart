import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'home_ui_builder_service.dart';
import 'home_animation_service.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Aggiungo import per le animazioni

/// Servizio per gestire i calcoli di layout e la costruzione della griglia nella home page
class HomeLayoutService {
  final HomeUiBuilderService _uiBuilder = HomeUiBuilderService();
  
  /// Calcola le dimensioni ottimali dei pulsanti in base alle dimensioni dello schermo
  Map<String, dynamic> calculateLayoutDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxGridWidth = 700.0;
    final gridWidth = min(screenWidth * 0.9, maxGridWidth);
    final contentWidth = screenWidth > 850 ? 800.0 : screenWidth * 0.9;
    
    const maxButtonSize = 160.0;
    const minButtonSize = 50.0;
    const totalHorizontalPadding = 80.0;
    final rawButtonSize = (gridWidth - totalHorizontalPadding) / 2;
    final buttonSize =
        screenWidth < 400 ? rawButtonSize.clamp(minButtonSize, maxButtonSize) : rawButtonSize.clamp(0.0, maxButtonSize);
    final buttonOffset = buttonSize * (50 / 160);
    
    return {
      'screenWidth': screenWidth,
      'gridWidth': gridWidth,
      'contentWidth': contentWidth,
      'buttonSize': buttonSize,
      'buttonOffset': buttonOffset,
    };
  }

  /// Costruisce la sezione della griglia e del calendario
  Widget buildGridAndCalendarSection(
    BuildContext context,
    double buttonSize, 
    double buttonOffset, 
    double contentWidth,
    HomeAnimationService animationService,
    Function(BuildContext) navigateToScanScreen,
    Function(BuildContext) navigateToPersonalPage,
    Function(BuildContext) navigateToVercelAppView,
    Function(BuildContext) navigateToDayCareQrScannerPage,
    Function(BuildContext) navigateToCalendarPage,
  ) {
    return Column(
      children: [
        // prima riga
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1: top‑left - animato da sinistra
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _uiBuilder.buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone5.png',
                icon: Icons.qr_code_scanner,
                iconColor: Colors.purple,
                splashColor: Colors.purple.withOpacity(0.3),
                highlightColor: Colors.purple.withOpacity(0.1),
                onTap: () => navigateToScanScreen(context),
              ),
            )
            .animate()
            .slideX(
              begin: -1.0, // Entra da sinistra
              end: 0.0,
              duration: 900.ms,
              curve: Curves.easeOutQuad,
              delay: 400.ms,
            )
            .fadeIn(
              duration: 700.ms,
              delay: 400.ms,
            ),
            const SizedBox(width: 10.0),
            // 2: top‑right - animato da destra
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _uiBuilder.buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone4.png',
                icon: Icons.person,
                iconColor: Colors.grey,
                splashColor: Colors.grey.withOpacity(0.3),
                highlightColor: Colors.grey.withOpacity(0.1),
                onTap: () => navigateToPersonalPage(context),
              ),
            )
            .animate()
            .slideX(
              begin: 1.0, // Entra da destra
              end: 0.0,
              duration: 900.ms,
              curve: Curves.easeOutQuad,
              delay: 400.ms,
            )
            .fadeIn(
              duration: 700.ms,
              delay: 400.ms,
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        // seconda riga
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 4: bottom‑left - animato dal basso
            Padding(
              padding: EdgeInsets.only(bottom: buttonOffset),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: _uiBuilder.buildNeumorphicButton(
                  backgroundImage: 'assets/images/sfondo_bottone3.png',
                  splashColor: Colors.blue.withOpacity(0.3),
                  highlightColor: Colors.blue.withOpacity(0.1),
                  onTap: () => navigateToVercelAppView(context),
                  child: const SizedBox.shrink(),
                ),
              ),
            )
            .animate()
            .slideY(
              begin: 1.0, // Entra dal basso
              end: 0.0,
              duration: 900.ms,
              curve: Curves.easeOutQuad,
              delay: 500.ms,
            )
            .fadeIn(
              duration: 700.ms,
              delay: 500.ms,
            ),
            const SizedBox(width: 10.0),
            // 3: bottom‑right +50px, Day Care with FlipCard - animato dall'alto
            Padding(
              padding: EdgeInsets.only(top: buttonOffset),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: FlipCard(
                  key: animationService.dayCareFlipKey,
                  flipOnTouch: false,
                  front: _uiBuilder.buildNeumorphicButton(
                    backgroundImage: 'assets/images/sfondo_bottone2.png',
                    deeper: true,
                    splashColor: Colors.teal.withOpacity(0.3),
                    highlightColor: Colors.teal.withOpacity(0.1),
                    onTap: () => navigateToDayCareQrScannerPage(context),
                    child: const Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                  back: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/daycar.png',
                        width: buttonSize * 0.8,
                        height: buttonSize * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .slideY(
              begin: -1.0, // Entra dall'alto
              end: 0.0,
              duration: 900.ms,
              curve: Curves.easeOutQuad,
              delay: 500.ms,
            )
            .fadeIn(
              duration: 700.ms,
              delay: 500.ms,
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // 5° rettangolo: calendario responsivo con bottom margin fisso
        Padding(
          padding: const EdgeInsets.only(bottom: 65.0),
          child: SizedBox(
            width: contentWidth,
            child: AspectRatio(
              aspectRatio: 366 / 290,
              child: _uiBuilder.buildNeumorphicButton(
                backgroundImage: 'assets/images/sfondo_bottone.png',
                splashColor: Colors.orange.withOpacity(0.3),
                highlightColor: Colors.orange.withOpacity(0.1),
                onTap: () => navigateToCalendarPage(context),
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
        )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOutBack,
          delay: 700.ms,
        )
        .fadeIn(
          duration: 600.ms,
          delay: 700.ms,
        ),
      ],
    );
  }
}