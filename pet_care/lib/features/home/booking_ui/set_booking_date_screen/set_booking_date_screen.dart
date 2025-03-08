import 'package:flutter/material.dart';

class SetBookingDateScreen extends StatefulWidget {
  final String doctorName;
  final String address;
  final double rating;
  final String image;

  SetBookingDateScreen({
    required this.doctorName,
    required this.address,
    required this.rating,
    required this.image,
  });

  @override
  _SetBookingDateScreenState createState() => _SetBookingDateScreenState();
}

class _SetBookingDateScreenState extends State<SetBookingDateScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _availableTimes = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt lịch hẹn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin bác sĩ
            _buildDoctorInfo(),
            SizedBox(height: 20),

            // Chọn ngày
            Text(
              'Chọn ngày',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildDatePicker(),
            SizedBox(height: 20),

            // Chọn giờ
            Text(
              'Chọn giờ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildTimePicker(),
            SizedBox(height: 20),

            // Nút đặt lịch
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedTime != null) {
                    _confirmBooking();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng chọn giờ')),
                    );
                  }
                },
                child: Text('Đặt lịch'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          // Thông tin bác sĩ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '📌 ${widget.address}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hiển thị tháng và năm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDate.month}/2024', // Hiển thị tháng và năm
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  // Hiển thị Date Picker Material 3
                  _showMaterial3DatePicker(context);
                },
              ),
            ],
          ),
          // Hiển thị lịch
          _buildCalendar(),
        ],
      ),
    );
  }

  void _showMaterial3DatePicker(BuildContext context) async {
    final DateTime now = DateTime.now(); // Lấy ngày hiện tại
    final DateTime lastDate = now.add(Duration(days: 365)); // Cho phép chọn trong vòng 1 năm

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate, // Đảm bảo initialDate không phải là ngày quá khứ
      firstDate: now, // Chỉ cho phép chọn từ ngày hiện tại
      lastDate: lastDate, // Cho phép chọn đến 1 năm sau
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCalendar() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        TableRow(
          children: [
            _buildDayHeader('CN'),
            _buildDayHeader('T2'),
            _buildDayHeader('T3'),
            _buildDayHeader('T4'),
            _buildDayHeader('T5'),
            _buildDayHeader('T6'),
            _buildDayHeader('T7'),
          ],
        ),
        ..._buildCalendarRows(),
      ],
    );
  }

  List<TableRow> _buildCalendarRows() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    List<TableRow> rows = [];
    List<Widget> currentRow = [];

    // Thêm các ô trống cho ngày đầu tháng
    for (int i = 1; i < firstWeekday; i++) {
      currentRow.add(_buildDayCell(''));
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      currentRow.add(_buildDayCell(day.toString()));
      if ((firstWeekday - 1 + day) % 7 == 0) {
        rows.add(TableRow(children: currentRow));
        currentRow = [];
      }
    }

    // Thêm các ô trống cho ngày cuối tháng
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(_buildDayCell(''));
      }
      rows.add(TableRow(children: currentRow));
    }

    return rows;
  }

  Widget _buildDayHeader(String day) {
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDayCell(String day) {
    final DateTime now = DateTime.now();
    final DateTime currentDay = DateTime(_selectedDate.year, _selectedDate.month, int.parse(day.isNotEmpty ? day : '0'));

    return GestureDetector(
      onTap: () {
        if (day.isNotEmpty && currentDay.isAfter(now.subtract(Duration(days: 1)))) {
          setState(() {
            _selectedDate = currentDay;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: day.isNotEmpty && _selectedDate.day == int.parse(day)
              ? Colors.blue.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          day,
          style: TextStyle(
            color: day.isNotEmpty ? (currentDay.isAfter(now.subtract(Duration(days: 1))) ? Colors.black : Colors.grey) : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableTimes.map((time) {
        return ChoiceChip(
          label: Text(time),
          selected: _selectedTime == time,
          onSelected: (selected) {
            setState(() {
              _selectedTime = selected ? time : null;
            });
          },
        );
      }).toList(),
    );
  }

  void _confirmBooking() {
    // Xử lý đặt lịch
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận đặt lịch'),
          content: Text('Bạn có chắc chắn muốn đặt lịch vào $_selectedTime ngày ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đặt lịch thành công!')),
                );
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}