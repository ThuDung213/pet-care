import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PetDiagnosisScreen extends StatelessWidget {
  final String petId;

  const PetDiagnosisScreen({Key? key, required this.petId}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa cập nhật";
    return DateFormat("dd.MM.yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('vet_records')
        .where('petId', isEqualTo: petId)
        .limit(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kết quả chẩn đoán",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có dữ liệu chẩn đoán"));
          }

          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          final DateTime? createdAt = data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null;
          final String diagnosis = data['diagnosis'] ?? "";
          final String treatment = data['treatment'] ?? "Không có dữ liệu";
          final String note = data['note'] ?? "Không có ghi chú";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diagnosis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow("Ngày khám", _formatDate(createdAt)),
                _buildInfoRow("Chẩn đoán", "${_formatDate(createdAt)}: $diagnosis"),
                _buildInfoRow("Điều trị", treatment),
                _buildInfoRow("Ghi chú", note),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
