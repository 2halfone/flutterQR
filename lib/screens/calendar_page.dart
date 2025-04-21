import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 850 ? 800.0 : screenWidth * 0.9;

    return Scaffold(
      extendBodyBehindAppBar: true, // Aggiungi questa linea per estendere l'immagine di sfondo dietro l'AppBar
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white, // Cambia a bianco per visibilità sullo sfondo scuro
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Mantieni trasparente
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Cambia a bianco per visibilità
      ),
      body: Stack(
        children: [
          // Il container principale con lo sfondo e il calendario
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgrounds/noir-pattern.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 100.0,
                left: 16.0,
                right: 16.0,
                bottom: 70.0,  // Aumentato per fare spazio alla barra inferiore
              ),
              child: Center(
                child: Container(
                  width: contentWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Week',
                          CalendarFormat.month: 'Month',
                        },
                        headerStyle: HeaderStyle(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 103, 96, 116),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                          formatButtonVisible: true,
                          formatButtonDecoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          formatButtonTextStyle: GoogleFonts.poppins(color: Colors.deepPurple.shade800, fontSize: 12),
                          headerMargin: const EdgeInsets.only(bottom: 8),
                        ),
                        calendarStyle: CalendarStyle(
                          cellMargin: const EdgeInsets.all(4),
                          defaultTextStyle: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
                          weekendTextStyle: GoogleFonts.poppins(color: Colors.redAccent),
                          todayTextStyle: GoogleFonts.poppins(color: Colors.deepPurple),
                          selectedTextStyle: GoogleFonts.poppins(color: Colors.white),
                          outsideDaysVisible: false,
                          selectedDecoration: const BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.poppins(color: Colors.white),
                          weekendStyle: GoogleFonts.poppins(color: Colors.redAccent),
                        ),
                      ),
                      
                      // Box che occupa lo spazio rimanente sotto il calendario
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 16.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 103, 96, 116).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _selectedDay != null 
                                  ? 'Selected: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                                  : 'Select a date',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
          
          // Posizioniamo la barra degli strumenti personalizzata in fondo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.payments_outlined, color: Colors.white),
                        onPressed: () {
                          // Implementa funzionalità pagamenti
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.paste, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}