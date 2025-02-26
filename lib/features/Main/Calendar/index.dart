import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String _currentView = 'Day';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildViewSelector(),
            _buildWeekCalendar(),
            Expanded(child: _buildSchedule()),
            _buildBottomActions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'October 2024',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildViewOption('List', Icons.list),
          _buildViewOption('Day', Icons.calendar_view_day),
          _buildViewOption('Week', Icons.calendar_view_week),
          _buildViewOption('Month', Icons.calendar_view_month),
        ],
      ),
    );
  }

  Widget _buildViewOption(String title, IconData icon) {
    final isSelected = _currentView == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentView = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = index == 4;
          return _buildDateItem(date, isSelected);
        }),
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      children: [
        Text(
          dayNames[date.weekday - 1],
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, index) {
        final hour = index.toString().padLeft(2, '0');
        if (index == 4) {
          return _buildEventItem(hour, 'Amir Design', Colors.blue[200]!);
        } else if (index == 7) {
          return _buildEventItem(hour, 'Amir Design', Colors.green[200]!);
        } else if (index == 9) {
          return _buildEventItem(hour, 'Amir Design', Colors.red[200]!);
        } else if (index == 11) {
          return _buildEventItem(hour, 'Amir Design', Colors.purple[200]!);
        }
        return _buildTimeSlot(hour);
      },
    );
  }

  Widget _buildTimeSlot(String hour) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$hour:00',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String hour, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$hour:00',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Text('A'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.calendar_today, 'Calendar'),
          _buildActionButton(Icons.access_time, 'Schedule'),
          _buildActionButton(Icons.location_on_outlined, 'Location'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, color: Colors.grey[600]),
    );
  }
}
