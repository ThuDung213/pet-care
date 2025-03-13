import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'PetDiagnosis/PetDiagnosisScreen.dart';

class PetDiagnosisListScreen extends StatelessWidget {
  final String petId;

  const PetDiagnosisListScreen({Key? key, required this.petId}) : super(key: key);

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Không có ngày";
    return DateFormat("dd.MM.yyyy").format(timestamp.toDate());
  }

  Future<String> _getDoctorName(String vetId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('vets').doc(vetId).get();
      return doc.exists ? (doc.data()?['name'] ?? "Không rõ bác sĩ") : "Không rõ bác sĩ";
    } catch (e) {
      return "Không rõ bác sĩ";
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('vet_records')
        .where('petId', isEqualTo: petId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ chẩn đoán"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
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

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String diagnosis = data['diagnosis'] ?? "Không có dữ liệu";
              final String vetId = data['vetId'] ?? "";
              final Timestamp? createdAt = data['createdAt'];

              return FutureBuilder<String>(
                future: _getDoctorName(vetId),
                builder: (context, doctorSnapshot) {
                  final String doctorName = doctorSnapshot.data ?? "Không rõ bác sĩ";

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                      title: Text(
                        diagnosis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "🗓 ${_formatDate(createdAt)}  |  👨‍⚕️ $doctorName",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetDiagnosisScreen(
                              diagnosis: data['diagnosis'] ?? "Không có dữ liệu",
                              vetId: data['vetId'] ?? "", 
                              createdAt: data['createdAt'],
                              treatment: data['treatment'] ?? "Không có thông tin điều trị",
                              note: data['note'] ?? "Không có ghi chú",
                            ),
                          ),
                        );
                      },



                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
