import 'package:activity_app/student_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students Ranking"),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('students').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // -------- حساب مجموع الدرجات لكل طالب وترتيبهم --------
          final students = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final grades = Map<String, dynamic>.from(data['grades']);

            int total = grades.values
    .map((e) => (e as num).toInt())
    .fold(0, (a, b) => a + b);


            return {
              "id": doc.id,
              "name": data['name'],
              "total": total,
            };
          }).toList();

          students.sort((a, b) => b['total'].compareTo(a['total']));

          // -------- عرض الترتيب --------
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                  title: Text(student["name"]),
                  trailing: Text(
                    "Total: ${student['total']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailsPage(
                          studentId: student["id"],
                          studentName: student["name"],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
