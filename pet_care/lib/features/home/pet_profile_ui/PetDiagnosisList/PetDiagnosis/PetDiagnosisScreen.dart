import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PetDiagnosisScreen extends StatefulWidget {
  final String diagnosis;
  final String vetId;  // Truyền vetId thay vì doctorName
  final Timestamp? createdAt;
  final String treatment;
  final String note;

  const PetDiagnosisScreen({
    Key? key,
    required this.diagnosis,
    required this.vetId,
    required this.createdAt,
    required this.treatment,
    required this.note,
  }) : super(key: key);

  @override
  _PetDiagnosisScreenState createState() => _PetDiagnosisScreenState();
}

class _PetDiagnosisScreenState extends State<PetDiagnosisScreen> {
  String doctorName = "Đang tải..."; // Giá trị mặc định khi chưa có dữ liệu

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    try {
      DocumentSnapshot vetDoc =
          await FirebaseFirestore.instance.collection('vets').doc(widget.vetId).get();
      if (vetDoc.exists) {
        setState(() {
          doctorName = vetDoc['name'] ?? "Không rõ bác sĩ";  // Đọc trường 'name'
        });
      } else {
        setState(() {
          doctorName = "Không tìm thấy bác sĩ";
        });
      }
    } catch (e) {
      setState(() {
        doctorName = "Lỗi tải dữ liệu";
      });
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Không có ngày";
    return DateFormat("dd.MM.yyyy").format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết chẩn đoán"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.calendar_today, "Ngày khám", _formatDate(widget.createdAt)),
            _buildDetailRow(Icons.person, "Bác sĩ", doctorName),
            _buildDetailRow(Icons.healing, "Chuẩn đoán", widget.diagnosis),
            _buildDetailRow(Icons.medical_services, "Điều trị", widget.treatment),
            _buildDetailRow(Icons.note, "Ghi chú", widget.note),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : "Không có thông tin",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
