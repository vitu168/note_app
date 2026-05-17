import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:note_app/l10n/app_localizations.dart';

// ── Event model ───────────────────────────────────────────────────────────────

class CambodiaEvent {
  final String name;
  final String nameKm;
  final EventType type;

  const CambodiaEvent({
    required this.name,
    required this.nameKm,
    required this.type,
  });
}

enum EventType { publicHoliday, royal, cultural, international, religious }

extension EventTypeX on EventType {
  Color get color {
    switch (this) {
      case EventType.publicHoliday:
        return const Color(0xFFE53935);
      case EventType.royal:
        return const Color(0xFF8E24AA);
      case EventType.cultural:
        return const Color(0xFFF57C00);
      case EventType.international:
        return const Color(0xFF1E88E5);
      case EventType.religious:
        return const Color(0xFF00897B);
    }
  }

  String localizedLabel(AppLocalizations s) {
    switch (this) {
      case EventType.publicHoliday:
        return s.eventTypePublicHoliday;
      case EventType.royal:
        return s.eventTypeRoyal;
      case EventType.cultural:
        return s.eventTypeCultural;
      case EventType.international:
        return s.eventTypeInternational;
      case EventType.religious:
        return s.eventTypeReligious;
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.publicHoliday:
        return Icons.flag_rounded;
      case EventType.royal:
        return Icons.stars_rounded;
      case EventType.cultural:
        return Icons.celebration_rounded;
      case EventType.international:
        return Icons.public_rounded;
      case EventType.religious:
        return Icons.brightness_3_rounded;
    }
  }
}

// ── Cambodia events 2025–2026 ─────────────────────────────────────────────────

Map<DateTime, List<CambodiaEvent>> _buildCambodiaEvents() {
  DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

  const shabbat = CambodiaEvent(
    name: 'Shabbat',
    nameKm: 'ថ្ងៃសប្ប័ត',
    type: EventType.religious,
  );

  final events = <DateTime, List<CambodiaEvent>>{
    // ── 2025 ──────────────────────────────────────────────────────────────────
    d(2025, 1, 1): [CambodiaEvent(name: 'International New Year', nameKm: 'ទិវាចូលឆ្នាំសាកល', type: EventType.international)],
    d(2025, 1, 7): [CambodiaEvent(name: 'Victory Day', nameKm: 'ទិវាជ័យជម្នះ', type: EventType.publicHoliday)],
    d(2025, 3, 8): [CambodiaEvent(name: "International Women's Day", nameKm: 'ទិវានារីអន្តរជាតិ', type: EventType.international)],
    d(2025, 4, 13): [CambodiaEvent(name: 'Khmer New Year (Day 1)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2025, 4, 14): [CambodiaEvent(name: 'Khmer New Year (Day 2)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2025, 4, 15): [CambodiaEvent(name: 'Khmer New Year (Day 3)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2025, 5, 1): [CambodiaEvent(name: 'International Labour Day', nameKm: 'ទិវាពលកម្មអន្តរជាតិ', type: EventType.international)],
    d(2025, 5, 14): [CambodiaEvent(name: "King Sihamoni's Birthday", nameKm: 'ព្រះរាជសម្ភពព្រះករុណា', type: EventType.royal)],
    d(2025, 5, 19): [CambodiaEvent(name: 'Royal Plowing Ceremony', nameKm: 'ព្រះរាជពិធីបុណ្យច្រត់ព្រះនង្គ័ល', type: EventType.royal)],
    d(2025, 6, 1): [CambodiaEvent(name: "International Children's Day", nameKm: 'ទិវាកុមារអន្តរជាតិ', type: EventType.international)],
    d(2025, 6, 18): [CambodiaEvent(name: "Queen Mother's Birthday", nameKm: 'ព្រះរាជសម្ភពព្រះវររាជមាតា', type: EventType.royal)],
    d(2025, 9, 24): [CambodiaEvent(name: 'Constitutional Day', nameKm: 'ទិវារដ្ឋធម្មនុញ្ញ', type: EventType.publicHoliday)],
    d(2025, 10, 1): [CambodiaEvent(name: 'Pchum Ben (Day 1)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2025, 10, 2): [CambodiaEvent(name: 'Pchum Ben (Day 2)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2025, 10, 3): [CambodiaEvent(name: 'Pchum Ben (Day 3)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2025, 10, 23): [CambodiaEvent(name: 'Paris Peace Agreement Day', nameKm: 'ទិវាសន្ធិសញ្ញាប៉ារីស', type: EventType.publicHoliday)],
    d(2025, 10, 29): [CambodiaEvent(name: "King's Coronation Day (Day 1)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី១)', type: EventType.royal)],
    d(2025, 10, 30): [CambodiaEvent(name: "King's Coronation Day (Day 2)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី២)', type: EventType.royal)],
    d(2025, 10, 31): [CambodiaEvent(name: "King's Coronation Day (Day 3)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី៣)', type: EventType.royal)],
    d(2025, 11, 5): [CambodiaEvent(name: 'Water Festival (Day 1)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2025, 11, 6): [CambodiaEvent(name: 'Water Festival (Day 2)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2025, 11, 7): [CambodiaEvent(name: 'Water Festival (Day 3)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2025, 11, 9): [CambodiaEvent(name: 'Independence Day', nameKm: 'ទិវាឯករាជ្យ', type: EventType.publicHoliday)],
    d(2025, 12, 10): [CambodiaEvent(name: 'International Human Rights Day', nameKm: 'ទិវាសិទ្ធិមនុស្ស', type: EventType.international)],

    // ── 2026 ──────────────────────────────────────────────────────────────────
    d(2026, 1, 1): [CambodiaEvent(name: 'International New Year', nameKm: 'ទិវាចូលឆ្នាំសាកល', type: EventType.international)],
    d(2026, 1, 7): [CambodiaEvent(name: 'Victory Day', nameKm: 'ទិវាជ័យជម្នះ', type: EventType.publicHoliday)],
    d(2026, 3, 8): [CambodiaEvent(name: "International Women's Day", nameKm: 'ទិវានារីអន្តរជាតិ', type: EventType.international)],
    d(2026, 4, 13): [CambodiaEvent(name: 'Khmer New Year (Day 1)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2026, 4, 14): [CambodiaEvent(name: 'Khmer New Year (Day 2)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2026, 4, 15): [CambodiaEvent(name: 'Khmer New Year (Day 3)', nameKm: 'ចូលឆ្នាំខ្មែរ (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2026, 5, 1): [CambodiaEvent(name: 'International Labour Day', nameKm: 'ទិវាពលកម្មអន្តរជាតិ', type: EventType.international)],
    d(2026, 5, 8): [CambodiaEvent(name: 'Royal Plowing Ceremony', nameKm: 'ព្រះរាជពិធីបុណ្យច្រត់ព្រះនង្គ័ល', type: EventType.royal)],
    d(2026, 5, 14): [CambodiaEvent(name: "King Sihamoni's Birthday", nameKm: 'ព្រះរាជសម្ភពព្រះករុណា', type: EventType.royal)],
    d(2026, 6, 1): [CambodiaEvent(name: "International Children's Day", nameKm: 'ទិវាកុមារអន្តរជាតិ', type: EventType.international)],
    d(2026, 6, 18): [CambodiaEvent(name: "Queen Mother's Birthday", nameKm: 'ព្រះរាជសម្ភពព្រះវររាជមាតា', type: EventType.royal)],
    d(2026, 9, 24): [CambodiaEvent(name: 'Constitutional Day', nameKm: 'ទិវារដ្ឋធម្មនុញ្ញ', type: EventType.publicHoliday)],
    d(2026, 10, 2): [CambodiaEvent(name: 'Pchum Ben (Day 1)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2026, 10, 3): [CambodiaEvent(name: 'Pchum Ben (Day 2)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2026, 10, 4): [CambodiaEvent(name: 'Pchum Ben (Day 3)', nameKm: 'បុណ្យភ្ជុំបិណ្ឌ (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2026, 10, 23): [CambodiaEvent(name: 'Paris Peace Agreement Day', nameKm: 'ទិវាសន្ធិសញ្ញាប៉ារីស', type: EventType.publicHoliday)],
    d(2026, 10, 29): [CambodiaEvent(name: "King's Coronation Day (Day 1)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី១)', type: EventType.royal)],
    d(2026, 10, 30): [CambodiaEvent(name: "King's Coronation Day (Day 2)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី២)', type: EventType.royal)],
    d(2026, 10, 31): [CambodiaEvent(name: "King's Coronation Day (Day 3)", nameKm: 'ព្រះរាជពិធីបុណ្យគ្រងរាជ្យ (ថ្ងៃទី៣)', type: EventType.royal)],
    d(2026, 11, 9): [CambodiaEvent(name: 'Independence Day', nameKm: 'ទិវាឯករាជ្យ', type: EventType.publicHoliday)],
    d(2026, 11, 21): [CambodiaEvent(name: 'Water Festival (Day 1)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី១)', type: EventType.cultural)],
    d(2026, 11, 22): [CambodiaEvent(name: 'Water Festival (Day 2)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី២)', type: EventType.cultural)],
    d(2026, 11, 23): [CambodiaEvent(name: 'Water Festival (Day 3)', nameKm: 'បុណ្យអុំទូក (ថ្ងៃទី៣)', type: EventType.cultural)],
    d(2026, 12, 10): [CambodiaEvent(name: 'International Human Rights Day', nameKm: 'ទិវាសិទ្ធិមនុស្ស', type: EventType.international)],
  };

  // Add weekly Shabbat (every Saturday) from Jan 4, 2025 through end of 2027
  DateTime sat = DateTime.utc(2025, 1, 4);
  while (!sat.isAfter(DateTime.utc(2027, 12, 31))) {
    events.putIfAbsent(sat, () => []).add(shabbat);
    sat = sat.add(const Duration(days: 7));
  }

  return events;
}

// ── Calendar Page ─────────────────────────────────────────────────────────────

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Map<DateTime, List<CambodiaEvent>> _events;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _events = _buildCambodiaEvents();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  List<CambodiaEvent> _eventsFor(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  List<MapEntry<DateTime, List<CambodiaEvent>>> _upcomingEvents() {
    final now = DateTime.now();
    return _events.entries
        .where((e) => !e.key.isBefore(DateTime.utc(now.year, now.month, now.day)))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final primary = context.primaryColor;
    final isDark = context.isDark;
    final s = AppLocalizations.of(context);
    final selectedEvents = _eventsFor(_selectedDay);
    final upcoming = _upcomingEvents();

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.cambodiaCalendar,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: t.titleText,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          s.calendarSubtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: t.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Legend ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: EventType.values.map((type) {
                    return _LegendChip(type: type);
                  }).toList(),
                ),
              ),
            ),

            // ── Calendar ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TableCalendar<CambodiaEvent>(
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2027, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _eventsFor,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focused) {
                      _focusedDay = focused;
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        border: Border.all(color: primary, width: 2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: GoogleFonts.poppins(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      defaultTextStyle: GoogleFonts.poppins(
                        color: t.titleText,
                        fontSize: 14,
                      ),
                      weekendTextStyle: GoogleFonts.poppins(
                        color: const Color(0xFFE53935),
                        fontSize: 14,
                      ),
                      outsideTextStyle: GoogleFonts.poppins(
                        color: t.bodyText.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      markersMaxCount: 3,
                      markerSize: 6,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                      cellMargin: const EdgeInsets.all(4),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        return Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: events.take(3).map((e) {
                              return Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: e.type.color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: GoogleFonts.poppins(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      titleTextStyle: GoogleFonts.poppins(
                        color: t.titleText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded, color: t.titleText),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded, color: t.titleText),
                      headerPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: GoogleFonts.poppins(
                        color: t.bodyText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: GoogleFonts.poppins(
                        color: const Color(0xFFE53935).withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Selected day events ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(_selectedDay),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: t.titleText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (selectedEvents.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${selectedEvents.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (selectedEvents.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: t.bodyText.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            color: t.bodyText, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          s.noEventsOnThisDay,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: t.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = selectedEvents[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _EventCard(event: event),
                    );
                  },
                  childCount: selectedEvents.length,
                ),
              ),

            // ── Upcoming events section ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  s.upcomingEvents,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: t.titleText,
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = upcoming[index];
                  final isToday = isSameDay(entry.key, DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _UpcomingEventRow(
                      date: entry.key,
                      events: entry.value,
                      isToday: isToday,
                      onTap: () {
                        setState(() {
                          _selectedDay = entry.key;
                          _focusedDay = entry.key;
                        });
                      },
                    ),
                  );
                },
                childCount: upcoming.length > 10 ? 10 : upcoming.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LegendChip extends StatelessWidget {
  final EventType type;
  const _LegendChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: type.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: type.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            type.localizedLabel(s),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: type.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CambodiaEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final s = AppLocalizations.of(context);
    final color = event.type.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(event.type.icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.titleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.nameKm,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: t.bodyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.type.localizedLabel(s),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventRow extends StatelessWidget {
  final DateTime date;
  final List<CambodiaEvent> events;
  final bool isToday;
  final VoidCallback onTap;

  const _UpcomingEventRow({
    required this.date,
    required this.events,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final primary = context.primaryColor;
    final s = AppLocalizations.of(context);
    final isKhmer = Localizations.localeOf(context).languageCode == 'km';
    final color = events.first.type.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? primary.withValues(alpha: 0.4)
                : t.bodyText.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isToday ? primary : color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isToday ? Colors.white : color,
                      height: 1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isToday ? Colors.white.withValues(alpha: 0.85) : color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKhmer ? events.first.nameKm : events.first.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.titleText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: t.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.today,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
            if (!isToday)
              Icon(Icons.chevron_right_rounded, color: t.bodyText, size: 18),
          ],
        ),
      ),
    );
  }
}
