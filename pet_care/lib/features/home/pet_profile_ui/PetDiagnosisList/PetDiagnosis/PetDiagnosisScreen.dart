import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PetDiagnosisScreen extends StatefulWidget {
  final String diagnosis;
  final String vetId;
  final Timestamp? createdAt;
  final String treatment;
  final String note;
  final List<String>? recordImg; // Chứa danh sách ảnh

  const PetDiagnosisScreen({
    Key? key,
    required this.diagnosis,
    required this.vetId,
    required this.createdAt,
    required this.treatment,
    required this.note,
    this.recordImg, // Nhận danh sách ảnh từ Firestore
  }) : super(key: key);

  @override
  _PetDiagnosisScreenState createState() => _PetDiagnosisScreenState();
}

class _PetDiagnosisScreenState extends State<PetDiagnosisScreen> {
  String doctorName = "Đang tải...";

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
          doctorName = vetDoc['name'] ?? "Không rõ bác sĩ";
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.calendar_today, "Ngày khám", _formatDate(widget.createdAt)),
            _buildDetailRow(Icons.person, "Bác sĩ", doctorName),
            _buildDetailRow(Icons.healing, "Chuẩn đoán", widget.diagnosis),
            _buildDetailRow(Icons.medical_services, "Điều trị", widget.treatment),
            _buildDetailRow(Icons.note, "Ghi chú", widget.note),
            const SizedBox(height: 20),
            _buildImageSection(), // Hiển thị ảnh
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

  Widget _buildImageSection() {
    if (widget.recordImg == null || widget.recordImg!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Không có ảnh chẩn đoán",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ảnh chẩn đoán:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Hiển thị 2 ảnh mỗi hàng
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.recordImg!.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showImageFullScreen(widget.recordImg![index]);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.recordImg![index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _showImageFullScreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }
}
